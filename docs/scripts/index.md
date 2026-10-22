# Scripts

可复用脚本存放在仓库根目录的 [`scripts/`](https://github.com/YangLab-SZBL/lab-resource/tree/main/scripts) 文件夹。
下方源码直接读取自该文件夹，修改脚本后网页会自动同步。

## bac.sh

用 Micromamba 创建名为 `bac_env` 的 Python 3.12 分析环境，安装常用科学计算与蛋白质组学包
（numpy、pandas、snakemake、pyteomics、biopython、parquet-tools 等），注册 Jupyter kernel 并逐项验证。

前置条件：已按 [Micromamba Environment](../hpc/micromamba.md) 安装 Micromamba，并已加载代理。

```bash
bash bac.sh
```

??? example "查看源码 `scripts/bac.sh`"

    ```bash
    --8<-- "scripts/bac.sh"
    ```

## fragpipe_gui.sh

在计算节点启动 FragPipe 图形界面，并带空闲看门狗：搜索完成且长时间无计算活动时，
自动关闭 FragPipe 并 `scancel` 释放节点。完整流程见
[FragPipe 指南 5.2](../hpc/3-FragPipe数据分析-salloc.html#s3)。

```bash
bash fragpipe_gui.sh              # 默认：连续 30 分钟无计算活动 → 自动退出
bash fragpipe_gui.sh 60           # 改为：连续 60 分钟无操作才退出
```

??? example "查看源码 `scripts/fragpipe_gui.sh`"

    ```bash
    --8<-- "scripts/fragpipe_gui.sh"
    ```

## 添加新脚本

1. 把脚本放进仓库 `scripts/` 目录，文件头写清用途、前置条件和用法。
2. 在本页按上面的格式新增一节，用 `--8<-- "scripts/<文件名>"` 嵌入源码。
