# 深圳湾实验室集群 iFlow CLI 终端 AI 配置指南

> **核心要点**：在集群环境中安装终端 AI，最核心的步骤是**先加载代理**，**用 Micromamba 管理依赖**，并**使用国内镜像源**。以下是从代理到启动的完整流程。

## 1. 加载集群外网代理
*下载外部软件包前必须执行，否则无法连接外网。*
```bash
source /lenovofs1/software/proxy/set_proxy.sh
```
*(如果使用的是1号集群，路径可能是 `/lustre/software/proxy/set_proxy.sh`)*

## 2. 使用 Micromamba 管理 Node.js 环境
*由于系统没有 sudo 权限，必须使用 Micromamba 在当前 Python 环境中安装 Node.js 和 npm，以此避开权限冲突。*
```bash
# 激活你的专属环境
micromamba activate bac_env

# 从 conda-forge 官方源（走代理）安装 nodejs
micromamba install -n bac_env -c conda-forge nodejs -y

# 刷新环境变量，使 node 和 npm 命令生效
hash -r

# 验证是否成功
node --version
npm --version
```

## 3. 使用国内镜像安装 iFlow CLI
*使用 npmmirror 镜像源，避免官方源连接超时。*
```bash
npm install -g @iflow-ai/iflow-cli --registry=https://registry.npmmirror.com
```

## 4. 启动并配置 iFlow
*程序安装完成后，直接启动。*
```bash
iflow
```
* **如果首次进入配置界面**：按要求输入 API Key 和 Base URL（通常可从 iFlow 官网获取）。
* **如果界面卡住无法按键**：按 `Ctrl+C` 强制退出，手动运行 `iflow` 重新进入。配置完成后，终端会保存记录，下次直接运行即可。

## ⚠️ 常见问题避坑 (FAQ)

| 问题现象 | 原因与解决方案 |
| :--- | :--- |
| `bash: iflow: command not found` | 未激活环境或没刷新 PATH。执行 `micromamba activate bac_env` 并 `hash -r` 后再试。 |
| `curl: (7) Failed to connect to npmmirror.com` | **忘记加载代理脚本**。必须先执行 Step 1 的 `source` 命令。 |
| 出现 `Failed to obtain authentication` 报错 | 不要回答 `y` 去让系统自动安装，这会因为权限不足而失败。一定要用 Micromamba 安装。 |
| `SyntaxError: Invalid regular expression flags` | Node.js 版本过旧（低于 v20）。使用 `micromamba install nodejs -y` 升级到最新稳定版。 |


### 💡 每日使用流程
以后每次登录集群，只需执行以下两步即可：
```bash
micromamba activate bac_env
iflow
```

### 申请节点来登陆 iflow
```
# 1. 在登录节点申请计算节点
[zxye@login01 ~]$ srun -p cu-1 -N 1 -n 1 --pty /bin/bash

# 2. 进入节点后（假设分配到了 cu184）
[zxye@cu184 ~]$ micromamba activate bac_env
(bac_env) [zxye@cu184 ~]$ source /lustre/software/proxy/set_proxy.sh
(bac_env) [zxye@cu184 ~]$ iflow

# 3. 使用完后退出节点
(bac_env) [zxye@cu184 ~]$ exit
```
