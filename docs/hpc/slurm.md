# Slurm Guide

常用命令速查。资源查看、交互式申请节点与 sbatch 脚本写法的完整说明，见
[HPC 使用入门 · 三、Slurm 作业基础](1-HPC使用入门.html#s3)。

## Submit a batch job

```bash
sbatch run.sbatch
```

## Check job status

```bash
squeue -u "$USER"
```

## See also

- [DIA-NN：sbatch 提交正式分析](../software/dia-nn.md)
- [FragPipe：salloc 申请节点运行图形界面](../software/fragpipe.md)
