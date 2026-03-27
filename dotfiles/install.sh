#!/usr/bin/env bash
# install.sh — bootstraps the full shell + vim + vscode setup
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$DOTFILES_DIR")"

info()    { echo "[info]  $*"; }
success() { echo "[ok]    $*"; }
warn()    { echo "[warn]  $*"; }

# ── 0. Submodules ─────────────────────────────────────────────────────────────
info "Initialising git submodules..."
git -C "$REPO_ROOT" submodule update --init --recursive
success "Submodules ready."

# ── 1. Zsh ────────────────────────────────────────────────────────────────────
if ! command -v zsh &>/dev/null; then
    info "Installing zsh..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y zsh
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y zsh
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm zsh
    else
        warn "Could not detect package manager — install zsh manually and re-run."
        exit 1
    fi
    success "zsh installed."
else
    info "zsh $(zsh --version) already installed — skipping."
fi

ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    info "Setting zsh as default shell..."
    # Ensure zsh is in /etc/shells
    if ! grep -qxF "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$ZSH_PATH"
    success "Default shell set to $ZSH_PATH — takes effect on next login."
else
    info "zsh is already the default shell."
fi

# ── 2. Fonts ──────────────────────────────────────────────────────────────────
info "Installing MesloLGS NF fonts..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cp "$REPO_ROOT/Fonts/"*.ttf "$FONT_DIR/"
fc-cache -f "$FONT_DIR"
success "Fonts installed. Set terminal font to 'MesloLGS NF' manually."

# ── 3. Oh My Zsh (from submodule) ────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Symlinking Oh My Zsh from submodule..."
    ln -sf "$DOTFILES_DIR/oh-my-zsh" "$HOME/.oh-my-zsh"
    success "~/.oh-my-zsh → submodule"
else
    info "~/.oh-my-zsh already exists — skipping."
fi

OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── 4. OMZ plugins ────────────────────────────────────────────────────────────
declare -A PLUGINS=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
    ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
)

for plugin in "${!PLUGINS[@]}"; do
    target="$OMZ_CUSTOM/plugins/$plugin"
    if [[ ! -d "$target" ]]; then
        info "Cloning $plugin..."
        git clone --depth=1 "${PLUGINS[$plugin]}" "$target"
    else
        info "$plugin already present — pulling latest..."
        git -C "$target" pull --ff-only
    fi
done

# ── 5. Powerlevel10k theme ────────────────────────────────────────────────────
P10K_DIR="$OMZ_CUSTOM/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    info "Cloning powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    info "powerlevel10k already present — pulling latest..."
    git -C "$P10K_DIR" pull --ff-only
fi

# ── 6. Dotfile symlinks ───────────────────────────────────────────────────────
info "Symlinking dotfiles..."

symlink() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        warn "Backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    success "Linked $dst → $src"
}

symlink "$DOTFILES_DIR/.zshrc"    "$HOME/.zshrc"
symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
symlink "$DOTFILES_DIR/.vimrc"    "$HOME/.vimrc"

# ── 7. NVM (from submodule) ─────────────────────────────────────────────────
if [[ ! -d "$HOME/.nvm" ]]; then
    info "Symlinking nvm from submodule..."
    ln -sf "$DOTFILES_DIR/nvm" "$HOME/.nvm"
    success "~/.nvm → submodule"
else
    info "~/.nvm already exists — skipping."
fi

# ── 8. Astral uv ─────────────────────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
    info "Installing astral uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    success "uv installed. It will be on PATH in new shells via ~/.local/bin."
else
    info "uv $(uv --version) already installed — skipping."
fi

# ── 9. Vim plug + plugins ────────────────────────────────────────────────────
info "Installing vim-plug..."
mkdir -p "$HOME/.vim/autoload"
cp "$DOTFILES_DIR/vim/autoload/plug.vim" "$HOME/.vim/autoload/plug.vim"

if command -v vim &>/dev/null; then
    info "Installing vim plugins (PlugInstall)..."
    vim +PlugInstall +qall
    success "Vim plugins installed."
else
    warn "vim not found — run :PlugInstall manually after installing vim."
fi

# ── 10. VS Code settings ────────────────────────────────────────────────────
VSCODE_SETTINGS_DIR="$HOME/.config/Code/User"
VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

if [[ -d "$VSCODE_SETTINGS_DIR" ]]; then
    info "Symlinking VS Code settings..."
    symlink "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_SETTINGS_FILE"
else
    warn "VS Code settings dir not found at $VSCODE_SETTINGS_DIR — skipping."
    warn "Once VS Code is installed, run:"
    warn "  ln -sf $DOTFILES_DIR/vscode/settings.json $VSCODE_SETTINGS_FILE"
fi

echo ""
success "Setup complete! Open a new terminal or run: source ~/.zshrc"
echo ""
info "Project templates are available in $REPO_ROOT/templates/"
info "To bootstrap a new project, run:"
info "  $REPO_ROOT/templates/init-project.sh /path/to/your/project"
