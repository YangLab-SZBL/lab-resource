# Lab Resources

<p>
  <a href="https://yanglab202606.github.io/lab-resource/"><img alt="Open website" src="https://img.shields.io/badge/%F0%9F%93%96%20Open%20Website-yanglab202606.github.io%2Flab--resource-A8BDA8?style=for-the-badge&labelColor=5F7A62"></a>
</p>

**👉 Website: <https://yanglab202606.github.io/lab-resource/>**

<img src="docs/assets/site-qr.png" alt="QR code for the website" width="140">

Guides for the SZBL HPC cluster, DIA-NN, FragPipe, and lab scripts. If you just need to look something up, open the website. You can skip the rest of this page.

---

## Adding or editing content

Everything can be done on the GitHub website. You don't need to install anything. A few minutes after you save, the website updates itself.

**Edit a page:** open the file (all pages are in `docs/`), click the pencil icon ✏️, make your changes, then click **Commit changes**.

**Add a page:**

1. Open the right folder:

   | Topic | Folder |
   | :--- | :--- |
   | Using the cluster | `docs/hpc/` |
   | A piece of software | `docs/software/` |
   | An analysis pipeline | `docs/workflows/` |
   | Errors and fixes | `docs/troubleshooting/` |
   | Images | `docs/assets/` |
   | Scripts | `scripts/` |

2. Click **Add file** → **Upload files** or **Create new file**. Use an English file name ending in `.md`, e.g. `maxquant.md`.
3. To make the page show up in the site menu, edit `mkdocs.yml` and add one line under `nav:`, lined up with the lines around it (use spaces, not tabs):

   ```yaml
     - Software:
         - DIA-NN: software/dia-nn.md
         - MaxQuant: software/maxquant.md   # new line
   ```

**Check the update:** open the **Actions** tab. ✅ green means it worked. ❌ red means something went wrong, but the website keeps its last working version. The usual causes are misaligned spaces in `mkdocs.yml` or a misspelled file name.

**Notes:**

- If you can't edit, ask an admin to add your GitHub account.
- This website is public. Never upload passwords, tokens, or unpublished data.
