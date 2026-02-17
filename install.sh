#!/usr/bin/env bash
# Installer for gw - Git Worktree Switcher
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
DIM='\033[2m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.local/bin"
BASH_COMPLETION_DIR="${HOME}/.local/share/bash-completion/completions"
ZSH_COMPLETION_DIR="${HOME}/.zsh/completions"

echo -e "${BOLD}Installing gw - Git Worktree Switcher${RESET}"
echo ""

# ─── Install binary ──────────────────────────────────────────────────────────

mkdir -p "$INSTALL_DIR"
cp "${SCRIPT_DIR}/gw" "${INSTALL_DIR}/gw"
chmod +x "${INSTALL_DIR}/gw"
echo -e "  ${GREEN}✓${RESET} Installed ${CYAN}gw${RESET} to ${DIM}${INSTALL_DIR}/gw${RESET}"

# Check PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
  echo -e "  ${DIM}⚠ ${INSTALL_DIR} is not in your PATH. Add it:${RESET}"
  echo -e "    export PATH=\"\${HOME}/.local/bin:\$PATH\""
fi

# ─── Install shell completions ───────────────────────────────────────────────

# Detect shell
CURRENT_SHELL="$(basename "${SHELL:-bash}")"

install_bash_completion() {
  mkdir -p "$BASH_COMPLETION_DIR"
  cp "${SCRIPT_DIR}/completions/gw.bash" "${BASH_COMPLETION_DIR}/gw"
  echo -e "  ${GREEN}✓${RESET} Bash completions → ${DIM}${BASH_COMPLETION_DIR}/gw${RESET}"

  # Check if bash-completion auto-loads from this dir
  local rc="${HOME}/.bashrc"
  if ! grep -q "gw.bash\|bash-completion/completions/gw" "$rc" 2>/dev/null; then
    echo "" >> "$rc"
    echo "# gw - Git Worktree Switcher completions" >> "$rc"
    echo "[ -f \"${BASH_COMPLETION_DIR}/gw\" ] && source \"${BASH_COMPLETION_DIR}/gw\"" >> "$rc"
    echo -e "  ${GREEN}✓${RESET} Added completion source to ${DIM}~/.bashrc${RESET}"
  fi
}

install_zsh_completion() {
  mkdir -p "$ZSH_COMPLETION_DIR"
  cp "${SCRIPT_DIR}/completions/_gw" "${ZSH_COMPLETION_DIR}/_gw"
  echo -e "  ${GREEN}✓${RESET} Zsh completions → ${DIM}${ZSH_COMPLETION_DIR}/_gw${RESET}"

  local rc="${HOME}/.zshrc"
  local needs_fpath=true
  local needs_compinit=true

  if grep -q "${ZSH_COMPLETION_DIR}" "$rc" 2>/dev/null; then
    needs_fpath=false
  fi
  if grep -q "compinit" "$rc" 2>/dev/null; then
    needs_compinit=false
  fi

  if $needs_fpath || $needs_compinit; then
    echo "" >> "$rc"
    echo "# gw - Git Worktree Switcher completions" >> "$rc"
    if $needs_fpath; then
      echo "fpath=(${ZSH_COMPLETION_DIR} \$fpath)" >> "$rc"
    fi
    if $needs_compinit; then
      echo "autoload -Uz compinit && compinit" >> "$rc"
    fi
    echo -e "  ${GREEN}✓${RESET} Updated ${DIM}~/.zshrc${RESET} with fpath"
  fi
}

# ─── Shell function wrapper (for cd support) ─────────────────────────────────

install_shell_function() {
  local rc="$1"
  local shell_name="$2"

  if ! grep -q "function gw\|gw()" "$rc" 2>/dev/null; then
    cat >> "$rc" <<'FUNC'

# gw - Git Worktree Switcher (shell function for cd support)
gw() {
  if [[ "${1:-}" == "" || "${1:-}" == "ls" || "${1:-}" == "list" || \
        "${1:-}" == "add" || "${1:-}" == "rm" || "${1:-}" == "remove" || \
        "${1:-}" == "help" || "${1:-}" == "--help" || "${1:-}" == "-h" || \
        "${1:-}" == "--version" || "${1:-}" == "-v" ]]; then
    command gw "$@"
  else
    # For switch: capture the target path and cd into it
    local target="$1"
    local dest
    dest=$(command gw --find-path "$target" 2>/dev/null)
    if [[ -n "$dest" && -d "$dest" ]]; then
      cd "$dest"
      echo -e "\033[0;32mSwitched to\033[0m \033[1m${target}\033[0m"
      echo -e "\033[2mBranch:\033[0m $(git branch --show-current 2>/dev/null || echo 'detached')"
      echo -e "\033[2mStatus:\033[0m $(git status --short | wc -l | tr -d ' ') changed files"
    else
      command gw "$@"
    fi
  fi
}
FUNC
    echo -e "  ${GREEN}✓${RESET} Added ${CYAN}gw()${RESET} shell function to ${DIM}${rc}${RESET} ${DIM}(enables cd on switch)${RESET}"
  fi
}

case "$CURRENT_SHELL" in
  zsh)
    install_zsh_completion
    install_shell_function "${HOME}/.zshrc" "zsh"
    ;;
  bash)
    install_bash_completion
    install_shell_function "${HOME}/.bashrc" "bash"
    ;;
  *)
    install_bash_completion
    echo -e "  ${DIM}ℹ Unknown shell '${CURRENT_SHELL}', installed bash completions.${RESET}"
    ;;
esac

echo ""
echo -e "${GREEN}${BOLD}Done!${RESET} Restart your shell or run: ${CYAN}source ~/.${CURRENT_SHELL}rc${RESET}"
echo ""
echo -e "${BOLD}Quick start:${RESET}"
echo -e "  ${CYAN}gw${RESET}              List worktrees"
echo -e "  ${CYAN}gw <name>${RESET}       Switch to a worktree (Tab to autocomplete!)"
echo -e "  ${CYAN}gw add <branch>${RESET} Create a new worktree"
echo -e "  ${CYAN}gw rm <name>${RESET}    Remove a worktree"
echo ""
