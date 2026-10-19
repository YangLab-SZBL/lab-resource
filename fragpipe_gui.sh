#!/bin/bash
# =============================================================================
# fragpipe_gui.sh —— 在【计算节点】启动 FragPipe 图形界面（窗口版），
#                    并带“空闲看门狗”：搜索完成且长时间无人操作时自动收尾，
#                    关闭 FragPipe（退出容器）并释放计算节点（结束计费）。
#
# 适用环境：SZBL HPC 一号集群（Slurm + Singularity；FragPipe 24.0 容器镜像）
# 前置条件：已在登录节点 salloc 申请到节点，并用 ssh -Y 登录进该计算节点
#          （完整流程见《FragPipe 数据分析（salloc）》指南 5.2 节）
#
# 用法（在【计算节点】上执行）：
#   bash fragpipe_gui.sh              # 默认：连续 30 分钟无计算活动 → 自动退出
#   bash fragpipe_gui.sh 60           # 改为：连续 60 分钟无操作才退出
#   bash fragpipe_gui.sh 30 123456    # 第二个参数可显式指定作业号（一般不必）
#
# 退出判定逻辑（“无操作”如何定义）：
#   · 看门狗每分钟统计一次本节点上你名下【所有进程】的 CPU 时间增量；
#   · 搜索运行期间 CPU 活跃 → 空闲计数清零，绝不会误退；
#   · 搜索结束后（含您暂离去忙别的）CPU 连续处于低谷，
#     累计达到设定分钟数 → 关闭 FragPipe、scancel 作业释放节点。
#   · 若你只想早点走：在运行本脚本的终端按 Ctrl+C，立即收尾退出。
#
# 注意：收尾时脚本会 scancel 你的 salloc 作业（这样才不需要手动两次 exit）。
#       届时 ssh 会话将断开、退回登录节点，属正常现象，不是报错。
# =============================================================================
set -u

# ---------------------------- 可调参数 ----------------------------
IDLE_LIMIT_MIN="${1:-30}"                        # 连续空闲多少分钟自动退出
CHECK_INTERVAL="${CHECK_INTERVAL:-60}"           # 检查周期（秒）
ACTIVE_CPU_PER_MIN="${ACTIVE_CPU_PER_MIN:-2}"    # 每分钟 CPU 增量 ≥ 该值(秒)视为“活跃”
WARN_LEFT_MIN=5                                  # 剩余多少分钟时开始提醒

SIF="/lustre/software/fragpipe/24.0/fragpipe-24.0-local.sif"
FP_BIN="/fragpipe_bin/fragpipe-24.0/fragpipe-24.0/bin/fragpipe"
WORKDIR="${FRAGPIPE_WORKDIR:-$PWD}"              # 数据目录（默认当前目录）

log(){ echo "[fragpipe_gui $(date '+%H:%M:%S')] $*"; }

# ----------------------- 0) 参数与前置检查 -----------------------
case "$IDLE_LIMIT_MIN" in ''|*[!0-9]*)
  log "空闲分钟数应为整数，收到：'$IDLE_LIMIT_MIN'"; exit 1 ;;
esac
[ "$IDLE_LIMIT_MIN" -ge 1 ] || { log "空闲分钟数至少为 1"; exit 1; }

[ -e "$SIF" ] || { log "找不到 FragPipe 镜像：$SIF"; exit 1; }

if [ -z "${DISPLAY:-}" ]; then
  log "未检测到 DISPLAY —— 当前会话没有图形（X11）转发。"
  log "请退出后改用 ssh -Y <计算节点名> 重新登录，再运行本脚本（见指南 5.1/5.2）。"
  exit 1
fi

cd "$WORKDIR" || { log "无法进入目录：$WORKDIR"; exit 1; }
log "工作目录：$WORKDIR"
log "空闲超时：连续 ${IDLE_LIMIT_MIN} 分钟无计算活动后自动退出"

# 运行位置检查：当前节点应属于你正在运行的 Slurm 作业（防止误在登录节点跑）
if command -v squeue >/dev/null 2>&1; then
  me="$(hostname -s)"
  if squeue -h -u "$USER" -t RUNNING -o "%N" 2>/dev/null | tr ',' '\n' | grep -qx "$me"; then
    log "已确认：当前节点 $me 属于你运行中的 Slurm 作业"
  else
    log "当前节点（$me）不在你运行中的 Slurm 作业里。"
    log "请按指南 5.2 先 salloc 申请节点，再 ssh -Y 进入计算节点后运行本脚本。"
    exit 1
  fi
fi

# 作业号（用于收尾时自动释放节点；ssh 不一定带 SLURM_JOB_ID，故再查一次）
JOBID="${SLURM_JOB_ID:-${2:-}}"
if [ -z "$JOBID" ]; then
  JOBID="$(squeue -h -u "$USER" -t RUNNING -o "%i %N" 2>/dev/null \
           | awk -v h="$(hostname -s)" '$2 ~ h {print $1; exit}')"
fi
if [ -n "$JOBID" ]; then
  log "作业号：$JOBID（收尾时将自动 scancel 释放）"
else
  log "提示：未能识别作业号，收尾时无法自动释放节点，需手动 scancel <作业号>"
fi

# 准备 singularity（脚本非交互环境里 module 可能尚未加载，尝试自动加载一次）
if ! command -v singularity >/dev/null 2>&1; then
  for f in /etc/profile.d/modules.sh /usr/share/Modules/init/bash; do
    [ -r "$f" ] && . "$f" 2>/dev/null
  done
  if command -v module >/dev/null 2>&1; then
    module load singularity/ce-3.8.0 2>/dev/null || true
  fi
fi
command -v singularity >/dev/null 2>&1 \
  || { log "未找到 singularity 命令，请先执行 module load singularity/ce-3.8.0 后重试"; exit 1; }

# ----------------------- 1) 启动 FragPipe -----------------------
log "启动 FragPipe（首次初始化约 5~20 分钟，窗口出现前请耐心等待）..."
singularity exec \
  --writable-tmpfs \
  --bind "$HOME/.Xauthority" \
  --env XAUTHORITY="$HOME/.Xauthority" \
  --env LC_ALL=C.UTF-8 \
  --env LANG=C.UTF-8 \
  "$SIF" "$FP_BIN" &
SING_PID=$!
log "FragPipe 已启动（容器进程号 $SING_PID），看门狗开始监测"

# ----------------------- 2) 空闲看门狗 -----------------------
# 统计本节点上当前用户所有进程的累计 CPU 秒数（cputime 格式 [[dd-]hh:]mm:ss → 秒）
user_cpu_seconds(){
  ps -u "$USER" -o cputime= 2>/dev/null | awk -F'[:.-]' '
    NF==4 {t += $1*86400 + $2*3600 + $3*60 + $4}
    NF==3 {t += $1*3600 + $2*60 + $3}
    NF==2 {t += $1*60 + $2}
    NF==1 {t += $1}
    END {print t+0}'
}

FINISHED=0
finish(){
  [ "$FINISHED" = 1 ] && return
  FINISHED=1
  trap - INT TERM
  echo
  if kill -0 "$SING_PID" 2>/dev/null; then
    log "正在关闭 FragPipe（先请它自行退出，最多等 30 秒）..."
    kill -TERM "$SING_PID" 2>/dev/null
    i=0
    while [ "$i" -lt 30 ] && kill -0 "$SING_PID" 2>/dev/null; do
      sleep 1; i=$((i+1))
    done
    if kill -0 "$SING_PID" 2>/dev/null; then
      log "仍未退出，强制结束容器进程"
      kill -KILL "$SING_PID" 2>/dev/null
    fi
  fi
  log "FragPipe / 容器已退出。"
  if [ -n "$JOBID" ] && command -v scancel >/dev/null 2>&1; then
    log "自动释放计算节点（scancel $JOBID）——本 ssh 会话将断开并退回登录节点，属正常现象。"
    scancel "$JOBID" 2>/dev/null && exit 0
  fi
  log "未能自动释放作业。请手动执行：scancel <作业号>；或先 exit 回登录节点再 exit。"
}
trap 'finish; exit 0' INT TERM

prev="$(user_cpu_seconds)"
idle=0
while kill -0 "$SING_PID" 2>/dev/null; do
  sleep "$CHECK_INTERVAL"
  kill -0 "$SING_PID" 2>/dev/null || break        # 用户自己关掉了 FragPipe 窗口
  now="$(user_cpu_seconds)"
  delta=$(( now - prev ))
  prev="$now"
  if [ "$delta" -lt "$ACTIVE_CPU_PER_MIN" ]; then
    idle=$((idle+1))
    left=$((IDLE_LIMIT_MIN - idle))
    log "空闲累计 ${idle}/${IDLE_LIMIT_MIN} 分钟（本分钟 CPU 增量 ${delta}s）"
    if [ "$left" -le 0 ]; then
      log "★ 连续空闲达到 ${IDLE_LIMIT_MIN} 分钟：开始自动收尾"
      break
    elif [ "$left" -le "$WARN_LEFT_MIN" ]; then
      log "☆ 提醒：约 ${left} 分钟后自动关闭；如需继续，请在 FragPipe 内继续操作任务"
    fi
  else
    if [ "$idle" -gt 0 ]; then
      log "检测到计算活动（本分钟 CPU 增量 ${delta}s），空闲计数清零"
    fi
    idle=0
  fi
done

finish
