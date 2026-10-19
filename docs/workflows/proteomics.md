# Proteomics Workflows

在 SZBL HPC 上完成蛋白质组学分析的推荐顺序。各步骤的具体命令与参数见对应指南。

1. **登录集群并上传数据** — [HPC Getting Started](../hpc/getting-started.md)
   （原始谱图、fasta、谱库等大文件先上传到集群再提交作业）
2. **配置个人环境（按需）** — [Micromamba Environment](../hpc/micromamba.md)，
   或使用脚本 [`bac.sh`](../scripts/index.md#bacsh) 一键创建 Python 分析环境
3. **选择分析软件**

    | 软件 | 运行方式 | 指南 |
    | :--- | :--- | :--- |
    | DIA-NN | sbatch 批处理（正式分析）/ 交互式调试 | [DIA-NN](../software/dia-nn.md) |
    | FragPipe | salloc 申请节点 + 图形界面 | [FragPipe](../software/fragpipe.md) |

4. **查看结果并释放资源** — 作业结束后及时退出节点或 `scancel`，避免持续计费；
   遇到问题先查 [Troubleshooting](../troubleshooting/common-errors.md)。
