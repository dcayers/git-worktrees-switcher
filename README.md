# gw — Git Worktree Switcher

A fast, intuitive CLI tool for managing and switching between git worktrees with tab completion.

## Features

- **Quick switch** — `gw feature-auth` jumps to a worktree by name or branch
- **Tab completion** — full autocomplete for worktree names, branches, and subcommands (bash & zsh)
- **Interactive picker** — if [fzf](https://github.com/junegunn/fzf) is installed, `gw switch` opens a fuzzy finder
- **Smart matching** — match by directory name or branch name
- **Shell integration** — `cd`s in your current shell (no subshell)
- **Zero dependencies** — pure bash, works everywhere git does

## Install

```bash
git clone <repo-url> && cd gw
./install.sh
```

The installer:
1. Copies `gw` to `~/.local/bin/`
2. Installs shell completions (bash or zsh, auto-detected)
3. Adds a shell function to your rc file so `gw <name>` actually `cd`s in your current shell

Restart your shell or `source ~/.zshrc` / `source ~/.bashrc` after installing.

## Usage

```
gw                        List all worktrees
gw <name>                 Switch to a worktree (Tab to autocomplete!)
gw ls                     List all worktrees
gw add <branch> [path]    Create a new worktree
gw rm <name>              Remove a worktree
gw help                   Show help
```

### Examples

```bash
# See all your worktrees
$ gw
Git Worktrees

  ▸ main                 a1b2c3d  main
    feature-auth         e4f5g6h  feature/auth
    hotfix-login         i7j8k9l  hotfix/login

# Switch (with tab completion!)
$ gw feat<TAB>
$ gw feature-auth
Switched to feature-auth
Branch: feature/auth
Status: 2 changed files

# Create a new worktree
$ gw add feat/payments
Creating worktree with new branch feat/payments
✓ Worktree created at /home/user/projects/feat-payments
  Run: gw feat/payments to switch to it

# Clean up
$ gw rm feature-auth
Removing worktree feature-auth (/home/user/projects/feature-auth)
  Are you sure? [y/N] y
✓ Worktree removed.
```

## How it works

- `gw` is installed as both a script (`~/.local/bin/gw`) and a shell function
- The shell function intercepts switch commands to `cd` in your current shell
- All other commands delegate to the script
- Completions query `git worktree list` in real-time, so they're always up to date

## Requirements

- Git 2.5+ (worktree support)
- Bash 4+ or Zsh 5+
- Optional: [fzf](https://github.com/junegunn/fzf) for interactive picker

## Uninstall

```bash
rm ~/.local/bin/gw
rm ~/.local/share/bash-completion/completions/gw  # bash
rm ~/.zsh/completions/_gw                          # zsh
# Remove the gw() function and completion source lines from your shell rc
```