# Lab Resources

<p>
  <a href="https://yanglab202606.github.io/lab-resource/"><img alt="Open website" src="https://img.shields.io/badge/%F0%9F%93%96%20Open%20Website-yanglab202606.github.io%2Flab--resource-A8BDA8?style=for-the-badge&labelColor=5F7A62"></a>
</p>

**👉 Website: <https://yanglab202606.github.io/lab-resource/>**

<img src="docs/assets/site-qr.png" alt="网站二维码" width="140">

课题组的 HPC 集群、DIA-NN、FragPipe 使用教程和常用脚本，都在上面这个网站里。只是查资料的话，打开网站就行，下面的内容不用看。

---

## 想添加或修改内容？

全程在 GitHub 网页上操作，不用装软件，也不用敲命令。提交后等几分钟，网站会自己更新。

### 改已有的文章

1. 在本页上方的文件列表里找到那篇文章（文章都在 `docs/` 文件夹里）。
2. 点开文件，再点右上角的铅笔图标 ✏️。
3. 改完点右上角的绿色按钮 **Commit changes**，再点一次确认。

### 加一篇新文章

1. 进入对应的文件夹：

   | 写的是什么 | 放进哪个文件夹 |
   | :--- | :--- |
   | 集群怎么用 | `docs/hpc/` |
   | 某个软件怎么用 | `docs/software/` |
   | 一整套分析流程 | `docs/workflows/` |
   | 报错和解决办法 | `docs/troubleshooting/` |
   | 图片 | `docs/assets/` |
   | 脚本（`.sh`、`.py` 等） | `scripts/` |

2. 点 **Add file**：已有文件就选 **Upload files** 直接拖进去，想现写就选 **Create new file**。文件名用英文，以 `.md` 结尾，例如 `maxquant.md`。
3. 点 **Commit changes** 保存。
4. **还差一步，网站菜单里才会出现这篇文章**：打开根目录的 `mkdocs.yml`，点铅笔图标，在 `nav:` 下面照着已有的格式加一行，例如：

   ```yaml
     - Software:
         - DIA-NN: software/dia-nn.md
         - MaxQuant: software/maxquant.md   # ← 新加的这一行
   ```

   每行开头的空格要和上一行对齐，不要用 Tab。

### 怎么知道网站更新好了？

点本页上方的 **Actions** 标签：

- 绿色 ✅：成功，过几分钟刷新网站就能看到。
- 红色 ❌：出错了，网站会保持上一个正常的版本，不会坏。点进去看报错，最常见的原因是 `mkdocs.yml` 的空格没对齐，或者链接的文件名写错了。

### 其他

- 没有修改权限的话，请找管理员把你的 GitHub 账号加进来。
- 不要上传密码、token、账号信息或未公开的样本数据。这个网站任何人都能打开。
- 维护者想在自己电脑上预览：`pip install -r requirements.txt`，再运行 `mkdocs serve`。
