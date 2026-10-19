# Lab Resources

A collection of useful resources for our lab — HPC guides, software tutorials, workflows, and scripts —
published as a documentation website with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).

Website: <https://yanglab202606.github.io/lab-resource/>

## Layout

```text
docs/                 Website content (Markdown; standalone HTML tutorials are served as-is)
  hpc/                Cluster guides (incl. the three SZBL HPC HTML tutorials)
  software/           Software guides
  workflows/          End-to-end analysis workflows
  scripts/            Script documentation page (embeds files from /scripts)
  troubleshooting/    FAQ index
  assets/extra.css    Site colors and styling
scripts/              Reusable executable scripts
mkdocs.yml            Site configuration and navigation
.github/workflows/    Automatic deployment to GitHub Pages
```

## Preview locally

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve          # open http://127.0.0.1:8000
```

## Add content

1. Add a Markdown file under the matching folder in `docs/`.
2. Add it to `nav:` in `mkdocs.yml`.
3. Check with `mkdocs build --strict`, then commit and push to `main` — the site deploys automatically.

New scripts go in `scripts/` and get a section on `docs/scripts/index.md`.
Images go in `docs/assets/`.

## Contributing

Feel free to contribute useful resources via pull requests. Please keep entries organized and include a brief description for each resource.
Do not commit credentials, tokens, or private sample data.
