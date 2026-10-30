# SFTP 文件传输

在本地 Mac 与 HPC 之间上传、下载文件，推荐使用 SFTP 传输节点 `10.68.247.101`（速度约 30 MB/s）。
节点说明见 [登录、文件传输与数据分析](<5-HPC 登录、文件传输与数据分析.md>)。

!!! info "约定"
    下文以用户 `zxye`、集群家目录 `/lustre/home/zxye` 为例，使用时替换成自己的用户名和路径。

## 1. 连接 { #connect }

在**本地终端**执行：

```bash
sftp zxye@10.68.247.101
```

输入邮箱提供的集群密码，看到 `Connected to 10.68.247.101.` 和 `sftp>` 提示符即连接成功。

!!! warning "`-P` 是端口参数"
    `sftp -P zxye@10.68.247.101` 会报错 `Bad port "zxye@10.68.247.101"`：`-P` 后面必须跟端口号。
    该节点使用默认端口，直接去掉 `-P` 即可；需要指定端口时写成 `sftp -P <端口> 用户名@IP`。

## 2. 远程与本地两套目录 { #dirs }

SFTP 会话里同时有两个“当前目录”：**远程（HPC）** 和 **本地（Mac）**。命令前加 `l`（local）即作用于本地。

| 作用 | 远程（HPC） | 本地（Mac） |
|---|---|---|
| 切换目录 | `cd /lustre/home/zxye` | `lcd ~/Downloads` |
| 查看当前目录 | `pwd` | `lpwd` |
| 列出文件 | `ls -lh` | `lls -lh` |
| 新建目录 | `mkdir results` | `lmkdir results` |

## 3. 下载：HPC → 本地 { #download }

推荐做法：先用 `lcd` 切到本地保存目录，再 `get`，文件会保存到该目录。

```text
sftp> cd /lustre/home/zxye
sftp> ls -lh diann_export_mc1_mc2.tsv.tar.gz
sftp> lcd ~/Downloads
sftp> get diann_export_mc1_mc2.tsv.tar.gz
```

| 需求 | 命令 |
|---|---|
| 下载单个文件 | `get file.tsv` |
| 下载并改名 | `get file.tsv new_name.tsv` |
| 下载整个文件夹 | `get -r results/` |
| 下载多个文件（通配符） | `get *.tsv` |
| 断点续传（中断后继续） | `reget file.tar.gz` |

!!! warning "本地路径不要写 `~`"
    `get file ~/Downloads/` 会报错 `open local "~/Downloads/": No such file or directory`：
    `get` / `put` 的本地路径参数不会展开 `~`。解决办法任选其一：

    - 先 `lcd ~/Downloads`，再 `get file`（推荐）；
    - 写完整路径：`get file /Users/<Mac用户名>/Downloads/`。

## 4. 上传：本地 → HPC { #upload }

```text
sftp> lcd ~/Desktop/project
sftp> cd /lustre/home/zxye/project
sftp> put sample.raw
sftp> put -r fasta/
```

| 需求 | 命令 |
|---|---|
| 上传单个文件 | `put file.raw` |
| 上传整个文件夹 | `put -r data/` |
| 上传多个文件（通配符） | `put *.raw` |
| 断点续传 | `reput file.raw` |

## 5. 大文件 / 多文件：先打包再传 { #tar }

大量小文件逐个传输很慢，先在 **HPC 终端**（SSH 登录节点）打包压缩，传一个文件即可：

```bash
# 打包压缩
tar -czvf diann_export_mc1_mc2.tsv.tar.gz diann_export_mc1_mc2.tsv

# 查看压缩包大小
ls -lh diann_export_mc1_mc2.tsv.tar.gz
```

下载到本地后，在 **Mac 终端** 解压：

```bash
cd ~/Downloads
tar -xzvf diann_export_mc1_mc2.tsv.tar.gz
```

## 6. 其他常用命令 { #misc }

| 命令 | 作用 |
|---|---|
| `rm file` | 删除远程文件 |
| `rename old new` | 重命名远程文件 |
| `!ls` | 在 sftp 内执行本地 shell 命令 |
| `help` | 查看全部命令 |
| `exit` / `bye` | 退出 sftp |

## 7. 不进入交互界面：scp 一行命令 { #scp }

偶尔传一两个文件时，可以直接在**本地终端**用 `scp`（这里的 `~` 由本地 shell 展开，可以正常使用）：

```bash
# 下载
scp zxye@10.68.247.101:/lustre/home/zxye/file.tar.gz ~/Downloads/

# 上传
scp ~/Desktop/sample.raw zxye@10.68.247.101:/lustre/home/zxye/

# 文件夹加 -r
scp -r zxye@10.68.247.101:/lustre/home/zxye/results ~/Downloads/
```

## 8. 常见报错速查 { #errors }

| 报错 | 原因 | 解决 |
|---|---|---|
| `Bad port "zxye@10.68.247.101"` | `-P` 后没写端口号 | 去掉 `-P`：`sftp zxye@10.68.247.101` |
| `open local "~/Downloads/": No such file or directory` | sftp 本地路径不展开 `~` | 先 `lcd ~/Downloads` 再 `get`，或写完整路径 |
| `No such file or directory`（远程） | 远程路径或文件名错误 | `pwd`、`ls` 确认当前目录和文件名 |
| `Permission denied` | 密码错误或无写权限 | 检查密码；上传到自己的家目录 |
