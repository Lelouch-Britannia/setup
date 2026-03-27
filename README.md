# setup

Personal environment setup — shell, editor, fonts, and project templates. Clone once, run the installer, and get a consistent dev environment on any Linux machine.

---

## Quick start

```bash
git clone --recurse-submodules <repo-url> ~/setup
cd ~/setup
bash dotfiles/install.sh
```

> `--recurse-submodules` is required to pull Oh My Zsh and nvm alongside the repo.

---

## What's included

```
setup/
├── Fonts/                  MesloLGS NF font family (Regular, Bold, Italic, Bold Italic)
├── dotfiles/
│   ├── .zshrc              Zsh config — OMZ settings, plugins, aliases, PATH
│   ├── .p10k.zsh           Powerlevel10k prompt layout
│   ├── .vimrc              Vim config + vim-plug plugin declarations
│   ├── vscode/
│   │   └── settings.json   Generic VS Code settings
│   ├── vim/autoload/
│   │   └── plug.vim        vim-plug bootstrapper
│   ├── oh-my-zsh/          Oh My Zsh (git submodule)
│   ├── nvm/                nvm (git submodule)
│   └── install.sh          Full bootstrap script
└── templates/              Reusable project config files
    ├── .gitignore
    ├── .dockerignore
    ├── .markdownlint.json
    ├── .yamllint
    ├── .pre-commit-config.yaml
    ├── commitlint.config.js
    ├── pyproject.toml
    └── init-project.sh     One-shot template copier
```

---

## install.sh — step by step

The installer is idempotent — safe to re-run on an existing machine.

| Step | What it does |
|------|-------------|
| 0 | `git submodule update --init --recursive` — ensures OMZ and nvm are populated |
| 1 | Copies `Fonts/*.ttf` → `~/.local/share/fonts` and runs `fc-cache` |
| 2 | Symlinks `dotfiles/oh-my-zsh` → `~/.oh-my-zsh` (no curl installer needed) |
| 3 | Clones the 4 custom OMZ plugins into `~/.oh-my-zsh/custom/plugins/` |
| 4 | Clones Powerlevel10k into `~/.oh-my-zsh/custom/themes/powerlevel10k` |
| 5 | Symlinks `.zshrc`, `.p10k.zsh`, `.vimrc` into `~` (backs up any existing files) |
| 6 | Symlinks `dotfiles/nvm` → `~/.nvm` |
| 7 | Installs [astral uv](https://docs.astral.sh/uv/) via the official installer |
| 8 | Copies `plug.vim` and runs `vim +PlugInstall +qall` |
| 9 | Symlinks `dotfiles/vscode/settings.json` → `~/.config/Code/User/settings.json` |

---

## Fonts

**MesloLGS NF** — the Nerd Font variant required by Powerlevel10k.

After running `install.sh`, set your terminal emulator font to `MesloLGS NF`. VS Code is already configured to use it via `settings.json`.

---

## Shell (Zsh + Oh My Zsh + Powerlevel10k)

- **Oh My Zsh** is pinned as a git submodule — update it with `git submodule update --remote dotfiles/oh-my-zsh`
- **Plugins** loaded (declared in `.zshrc`):
  - `zsh-autosuggestions` — inline command suggestions
  - `zsh-completions` — extended tab completions
  - `zsh-syntax-highlighting` — real-time syntax colouring
  - `zsh-history-substring-search` — history search with Up/Down arrows
- **Theme**: Powerlevel10k — all prompt customisation lives in `.p10k.zsh`. Re-run `p10k configure` at any time to regenerate it.

---

## Vim

Plugins managed by [vim-plug](https://github.com/junegunn/vim-plug):

| Plugin | Purpose |
|--------|---------|
| `vim-sensible` | Sensible defaults |
| `vim-commentary` | `gc` to comment/uncomment |
| `nerdtree` | File tree sidebar |
| `vim-airline` | Status bar |
| `fzf.vim` | Fuzzy finder |

To install manually after a fresh clone: open vim and run `:PlugInstall`.

---

## VS Code

`dotfiles/vscode/settings.json` contains generic editor settings:

- Font: `MesloLGS NF`
- Theme: Monokai Dimmed + vscode-icons
- Relative line numbers, right sidebar
- Python formatter: Ruff (format on save + organise imports)
- Notebook formatter: Ruff
- LaTeX: latexmk (lualatex), auto-build on file change
- Vim keybindings with `<C-b>`, `<C-j>`, `<C-f>`, `<C-p>` passed through to VS Code

> Machine-specific settings (SSH hosts, tool paths, DB connections) are **not** included — add those locally without committing them.

---

## nvm

nvm is pinned as a git submodule. The installer symlinks it to `~/.nvm`. It will be sourced automatically if `.zshrc` includes the standard nvm initialisation lines.

To install a Node version after setup:

```bash
nvm install --lts
nvm use --lts
```

To update nvm: `git submodule update --remote dotfiles/nvm`

---

## Project templates

The `templates/` directory contains reusable config files for Python projects.

### Bootstrap a new project

```bash
~/setup/templates/init-project.sh /path/to/new-project
```

This copies all templates into the target directory, skipping any files that already exist.

### What gets copied

| File | Purpose |
|------|---------|
| `.gitignore` | Python, venv, IDE, log, and build artefact ignores |
| `.dockerignore` | Keeps images lean — excludes venvs, caches, test output |
| `.markdownlint.json` | Line length 150, relaxed HTML/heading rules |
| `.yamllint` | YAML style rules — errors on trailing spaces, colons, indentation |
| `.pre-commit-config.yaml` | Ruff, Hadolint, pre-commit-hooks, ShellCheck, markdownlint |
| `commitlint.config.js` | Enforces `Type: Summary` commit format |
| `pyproject.toml` | Ruff + pytest config template — fill in `[project]` fields |

### After bootstrapping

1. Edit `pyproject.toml` — set `name`, `authors`, `dependencies`, and `[tool.uv.workspace]` members
2. Install pre-commit hooks: `pre-commit install`
3. Install dependencies: `uv sync`

### Commit message format

```
Type: Short summary of the change
```

Allowed types: `Feat`, `Fix`, `Chore`, `Refactor`, `Docs`, `Test`, `Update`

---

## Updating submodules

```bash
# Update both submodules to their latest remote commits
git submodule update --remote

# Update a single submodule
git submodule update --remote dotfiles/oh-my-zsh
git submodule update --remote dotfiles/nvm
```

Commit the result to pin the new version.
