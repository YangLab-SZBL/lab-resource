# 深圳湾实验室 HPC SSH 连接与 Qoder CLI 使用指南

## 一、整体流程

使用 Qoder CLI 的基本流程：

1. 通过 SSH 登录 HPC。
2. 使用 Slurm 申请交互式计算节点。
3. 激活所需的软件环境。
4. 加载实验室代理配置。
5. 安装或检查 Qoder CLI。
6. 启动 Qoder CLI。

**注意：** SSH 登录成功不代表已经获得计算节点资源。`srun` 用于申请交互式计算资源，具体分区和资源规则以实验室管理员的最新说明为准。

---

## 二、SSH 登录 HPC

在本地电脑的终端中执行：

```bash
ssh uu1s5v865@10.68.247.110 -p 8022
```
这个IP地址也是深圳湾实验室提供的，节点名称叫行云堡垒机，1，2号集群共用，相比于别的节点，这个可以在终端直接用ssh登陆远程连接，如果想用ssh登陆，最好用这个节点。

### 命令解释

| 参数 | 含义 |
|---|---|
| `ssh` | 使用 SSH 协议连接远程服务器 |
| `uu1s5v865` | HPC 登录账号 |
| `10.68.247.110` | HPC 服务器 IP 地址 |
| `-p 8022` | 指定 SSH 端口为 8022 |

连接成功后，如果系统要求输入密码，请输入实验室提供的密码。

**注意：** 输入密码时，终端通常不会显示字符或星号，这是正常现象。

常见问题：

- `Permission denied`：检查用户名、密码或认证方式。
- `Connection timed out`：检查网络、VPN、端口连通性及服务器状态。

---

## 三、确认当前账号和节点

登录后执行：

```bash
whoami
hostname
```

作用：

- `whoami`：查看当前登录账号。
- `hostname`：查看当前所在的服务器或节点名称。

确认账号和节点信息有助于判断当前处于登录节点还是计算节点。

---

## 四、申请计算节点（交互式测试）

需要交互式测试时，按实验室规定通过 Slurm 申请资源。

当前使用的 CPU 交互式示例：

```bash
srun -p cu-1 -N 1 -n 1 --pty bash
```

### 参数解释

| 参数 | 含义 |
|---|---|
| `srun` | 向 Slurm 调度系统提交任务 |
| `-p cu-1` | 指定使用 `cu-1` 分区 |
| `-N 1` | 请求 1 个节点 |
| `-n 1` | 请求 1 个任务 |
| `--pty` | 请求交互式伪终端 |
| `bash` | 启动 Bash Shell |

成功后，提示符可能类似：

```text
[zxye@cu315 ~]$
```

实际提示符取决于账号和分配到的节点。

检查当前节点：

```bash
hostname
```

退出交互式计算节点：

```bash
exit
```

### 注意事项

- `-N 1 -n 1` 表示请求一个节点和一个任务，不代表申请了一张 GPU。
- 不要在 CPU 分区中随意添加 `--gres=gpu:1`，除非管理员明确说明该分区支持 GPU 资源。
- 如果提示分区不可用、资源不足或参数不支持，不要反复猜参数，应查看 HPC 文档或联系管理员。
- 正式 DIA-NN 或其他长时间分析通常应编写作业脚本并使用 `sbatch` 提交，不要长期占用交互式终端。

---

## 五、安装 Qoder CLI（通常只需安装一次）

仅在实验室政策允许使用外部 AI 编程工具、且网络策略允许的情况下操作。

### 5.1 确认当前账号和节点

```bash
whoami
hostname
```

进入允许联网的 HPC Shell 后，再执行安装操作。

### 5.2 使用 Qoder 中国站安装脚本

历史操作记录中的安装命令为：

```bash
curl -fsSL https://qoder.com.cn/install | bash
```

参数说明：

- `curl`：请求并下载网络资源。
- `-f`：HTTP 请求失败时返回错误。
- `-sS`：减少普通输出，但保留错误信息。
- `-L`：跟随 HTTP 重定向。
- `| bash`：将下载的脚本传给 Bash 执行。

**安全提醒：** 这条命令会直接执行远程脚本。执行前应确认 URL 是官方提供的地址，并遵守实验室的软件安装和网络使用政策。也可以先下载脚本并检查内容，再执行。

### 5.3 更新当前终端的 PATH

安装完成后，当前终端可能还没有识别新安装的命令。

执行：

```bash
export PATH="$HOME/.local/bin:$PATH"
hash -r
```

说明：

- `$HOME`：当前用户的主目录。
- `~/.local/bin`：用户级程序常见的安装目录。
- `PATH`：Shell 搜索可执行程序时使用的目录列表。
- `hash -r`：清除 Bash 缓存的命令路径。

### 5.4 检查安装结果

根据历史安装记录，当前环境中的命令名是 `qoderclicn`，而不是 `qodercn`。

检查文件是否存在：

```bash
ls -l ~/.local/bin/qoderclicn
```

检查版本：

```bash
~/.local/bin/qoderclicn --version
```

如果能够正常显示版本号，说明该路径下的 CLI 可以运行。

**注意：** 命令名和安装路径可能随版本或安装脚本变化，应以实际安装输出和官方文档为准。

### 5.5 让新终端自动识别命令

确认命令可以正常运行后，再执行一次：

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

作用：

- 将用户级程序目录加入 Bash 的启动配置。
- `source ~/.bashrc` 让配置在当前 Bash 中生效。

不要因为命令暂时找不到就重复安装。

---

## 六、激活软件环境

如果当前工作流程需要使用 `bac_env` 环境，执行：

```bash
micromamba activate bac_env
```

作用：

- `micromamba`：管理 Conda 兼容的软件环境。
- `activate`：激活指定环境。
- `bac_env`：需要预先存在的环境名称。

检查环境：

```bash
micromamba env list
which python
python --version
```

如果提示环境不存在，应先检查环境名称和配置。

注意：Qoder CLI 是否依赖 `bac_env`，取决于实际安装方式。激活该环境主要是为了满足你的其他分析工具或工作流程的依赖需求。

---

## 七、加载 HPC 代理配置

执行：

```bash
source /lustre/software/proxy/set_proxy.sh
```

作用：

- `source`：在当前 Shell 中执行脚本。
- `set_proxy.sh`：实验室提供的代理配置脚本。
- `/lustre/software/proxy/`：脚本所在的路径。

代理可能用于帮助需要访问外部服务的程序连接网络。

检查代理相关环境变量：

```bash
env | grep -i proxy
```

注意：

- 加载代理不代表外网一定可访问。
- 代理是否生效取决于脚本配置、代理服务状态和网络策略。
- 如果退出当前 Shell 后重新进入计算环境，应重新检查代理配置。
- 不要将代理地址、认证信息或其他敏感配置公开分享。

---

## 八、日常启动 Qoder CLI

安装完成后，通常不需要每次重新安装。

### 8.1 登录 HPC

在本地电脑终端执行：

```bash
ssh uu1s5v865@10.68.247.110 -p 8022
```

### 8.2 申请交互式计算节点

登录成功后执行：

```bash
srun -p cu-1 -N 1 -n 1 --pty bash
```

### 8.3 准备环境

进入交互式 Shell 后执行：

```bash
micromamba activate bac_env
source /lustre/software/proxy/set_proxy.sh
export PATH="$HOME/.local/bin:$PATH"
hash -r
```

### 8.4 检查并启动 CLI

```bash
qoderclicn --version
qoderclicn
```

如果 `qoderclicn` 已经在 `PATH` 中，就不需要每次重新设置 `PATH`。如果命令无法找到，先检查安装位置和环境配置。

---

## 九、常见问题排查

### 9.1 `qoderclicn: command not found`

先执行：

```bash
ls -l ~/.local/bin/qoderclicn
export PATH="$HOME/.local/bin:$PATH"
hash -r
```

如果文件存在，通常是 `PATH` 没有配置好；如果文件不存在，再检查实际安装位置和安装日志。

### 9.2 安装脚本下载失败

检查网络：

```bash
curl -I https://qoder.com.cn/install
```

如果无法连接，检查 HPC 网络策略和代理配置。不要反复执行安装脚本来解决网络问题。

### 9.3 `micromamba activate` 失败

检查环境：

```bash
micromamba env list
```

如果环境存在但无法激活，可能需要按照实验室的配置初始化 Shell。

### 9.4 Qoder CLI 无法访问服务

检查代理：

```bash
env | grep -i proxy
```

如果代理已加载但仍然无法连接，需要进一步检查代理服务、目标地址的可达性以及实验室的网络策略。

### 9.5 退出计算节点

执行：

```bash
exit
```

退出交互式 Shell 后，Slurm 分配的资源通常会释放。下次使用时，应重新申请交互式计算节点。

---

## 十、官方文档

- Qoder 中国站：<https://qoder.com.cn/>
- Qoder CLI 安装文档：<https://docs.qoder.cn/cli/installation>
- Qoder CLI 故障排查：<https://docs.qoder.cn/cli/troubleshoot-install>

实际安装命令、CLI 名称和支持的系统版本可能随官方版本变化。若文档与本地安装结果不一致，应优先核对当前版本的官方说明。

---

## 十一、核心命令速查

| 用途 | 命令 |
|---|---|
| SSH 登录 | `ssh uu1s5v865@10.68.247.110 -p 8022` |
| 申请交互式节点 | `srun -p cu-1 -N 1 -n 1 --pty bash` |
| 查看当前账号 | `whoami` |
| 查看当前节点 | `hostname` |
| 激活软件环境 | `micromamba activate bac_env` |
| 加载代理 | `source /lustre/software/proxy/set_proxy.sh` |
| 更新当前 PATH | `export PATH="$HOME/.local/bin:$PATH"` |
| 检查 CLI 版本 | `qoderclicn --version` |
| 启动 CLI | `qoderclicn` |
| 退出交互式节点 | `exit` |

**最重要的原则：** SSH 登录、申请计算资源、准备运行环境和启动 CLI 是不同的步骤。安装一般只需完成一次；每次新开计算环境时，应检查 `PATH`、软件环境和代理是否仍然有效。
