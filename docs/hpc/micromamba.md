# 深圳湾实验室 (SZBL) 集群 Micromamba 环境配置指南

> **本文档更新记录**：针对 1号集群（`ln01`/`ln02`）和 2号集群（`login03`/`login04`）环境不共享的特点做了适配。重点解决了直接使用 `curl` 下载后权限冲突、`node/npm` 找不到、以及登录节点卡死等问题。
> 
> **🔑 核心经验**：**在集群中，尽量不要手动解压软件包！** 只要网络代理通了，优先使用 `micromamba` 自身去下载软件（如 Node.js），这会自动配置好路径和环境变量，完美避开权限冲突。

## 📌 前置条件
1. 已成功登录 1号或 2号集群。
2. **必须满足**：集群能访问互联网（需加载代理脚本）。

---

## 1️⃣ 加载上网代理脚本（下载外部数据/软件必须）
*在从互联网下载 Micromamba 或安装包之前，必须先加载集群提供的代理设置。*

**根据你所处的集群节点，选择对应的脚本路径执行：**
```bash
# 【1号集群 (ln01/ln02)】推荐路径
source /lustre/software/proxy/set_proxy.sh

# 【2号集群 (login03/login04)】推荐路径
source /lenovofs1/software/proxy/set_proxy.sh
```

**测试是否能访问互联网：**
```bash
curl -I www.baidu.com
# 如果能返回 HTTP/1.1 200 OK 或 HTML 代码，则说明代理已生效。
```

---

## 2️⃣ 下载并配置 Micromamba (标准做法)
*注意：集群中 `~/.local/bin` 可能没有权限，因此我们直接将 Micromamba 下载到当前用户目录下，并用绝对路径调用，最稳妥。*

```bash
# 2.1 下载并解压到当前目录
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba

# 2.2 移入个人 bin 目录
mkdir -p ~/.local/bin
mv bin/micromamba ~/.local/bin

# 2.3 永久添加 PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# 2.4 验证是否成功
micromamba --version
```
*(如果 `mv` 时报权限拒绝，请改用 `cp` 复制过去)*

---

## 3️⃣ 初始化 Shell (必须执行)
*这一步是为了让 `micromamba activate` 命令能正常在 Shell 中生效。*

```bash
# 初始化 shell，指定 root-prefix
micromamba shell init --shell bash --root-prefix=~/.local/share/mamba

# 重新加载配置
source ~/.bashrc
```

---

## 4️⃣ 使用 Micromamba 统一管理环境 (强烈推荐)
*重要提示：不要手动下载 Node.js！直接使用 micromamba 安装，能自动解决依赖冲突，且能在所有节点保持路径一致。*

### 4.1 创建环境
```bash
# 建议不同的集群使用不同的环境名，以防混淆
micromamba create -n bac_env -y
```

### 4.2 激活环境
```bash
micromamba activate bac_env
# 如果看到命令行前缀变为 (bac_env)，说明成功！
```

### 4.3 在环境中安装 Node.js (避开权限坑的关键一步)
*很多工具（如 iFlow CLI）需要 Node.js。使用 micromamba 安装会自动处理好路径问题，不会出现“找不到 npm”的报错。*
```bash
micromamba install -c conda-forge nodejs -y
# 验证
node --version
npm --version
```

---

## 5️⃣ 集群作业注意事项 (非常重要)
*登录节点（如 ln01, login03）是公共资源，不要直接在登录节点上长期跑交互式任务（如 iFlow），否则容易卡死或被管理员警告。*

**配合 `srun` 申请免费 CPU 节点运行：**
```bash
# 假设你有安装好的工具 (例如 iflow)
micromamba activate bac_env

# 申请 2 小时交互式 CPU 节点
srun --partition=cpu --time=02:00:00 --pty bash -i

# 进入计算节点后，需要重新激活环境
micromamba activate bac_env

# 运行工具
iflow
```

---

## ⚠️ 常见问题排坑 (FAQ)
* **遇到 `bash: iflow: command not found`**：请确保已激活环境（`micromamba activate bac_env`），并执行了 `hash -r` 刷新路径。
* **遇到权限报错 `Failed to obtain authentication`**：千万不要输入 `y` 让系统自动安装！直接使用 `micromamba install` 或 `npm install --prefix ~/.local` 安装到个人目录。
* **1号集群与2号集群文件不互通**：如果在 2号集群安装好的环境，去 1号集群是找不到的。需要在每个集群单独执行本指南的步骤 1-4。
