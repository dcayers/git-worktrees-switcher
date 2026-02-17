# Bash completion for gw (Git Worktree Switcher)
# Source this file or place in /etc/bash_completion.d/

_gw_completions() {
  local cur prev commands
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  commands="ls list add new rm remove delete help"

  # If we're completing the first argument
  if [[ ${COMP_CWORD} -eq 1 ]]; then
    # Combine subcommands + worktree names
    local worktrees
    worktrees=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree / { path=substr($0,10); n=path; gsub(/.*\//, "", n); print n }')
    COMPREPLY=( $(compgen -W "${commands} ${worktrees}" -- "$cur") )
    return 0
  fi

  # If completing args after 'add', offer branch names
  if [[ "$prev" == "add" || "$prev" == "new" ]]; then
    local branches
    branches=$(git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)
    COMPREPLY=( $(compgen -W "${branches}" -- "$cur") )
    return 0
  fi

  # If completing args after 'rm'/'remove'/'delete', offer worktree names
  if [[ "$prev" == "rm" || "$prev" == "remove" || "$prev" == "delete" ]]; then
    local worktrees
    worktrees=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree / { path=substr($0,10); n=path; gsub(/.*\//, "", n); print n }')
    COMPREPLY=( $(compgen -W "${worktrees}" -- "$cur") )
    return 0
  fi
}

complete -F _gw_completions gw
