#!/usr/bin/env bash
# init-project.sh — copies dev config templates into a new project directory
# Usage: ./init-project.sh [target-dir]
#   target-dir defaults to the current working directory
set -euo pipefail

TEMPLATES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$PWD}"

info()    { echo "[info]  $*"; }
success() { echo "[ok]    $*"; }
warn()    { echo "[warn]  $*"; }

if [[ ! -d "$TARGET" ]]; then
    echo "Error: target directory '$TARGET' does not exist." >&2
    exit 1
fi

FILES=(
    ".gitignore"
    ".dockerignore"
    ".markdownlint.json"
    ".yamllint"
    ".pre-commit-config.yaml"
    ".gitmessage"
    "commitlint.config.js"
    "pyproject.toml"
)

info "Copying templates into $TARGET ..."
for f in "${FILES[@]}"; do
    dst="$TARGET/$f"
    if [[ -e "$dst" ]]; then
        warn "$f already exists — skipping (remove it first to overwrite)."
    else
        cp "$TEMPLATES_DIR/$f" "$dst"
        success "Copied $f"
    fi
done

echo ""
success "Done. Next steps:"
echo "  1. Edit pyproject.toml — update [project] name, author, deps & workspace members"
echo "  2. Run: git init && git config commit.template .gitmessage"
echo "  3. Run: pre-commit install"
echo "  4. Run: uv sync"
