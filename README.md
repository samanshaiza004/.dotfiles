# Dotfiles

Personal configuration files for my Linux environment.

This repository manages my shell, tmux, editor, and related tooling using a bare Git repository approach. The actual config files live in $HOME, and Git tracks them via a separate .dotfiles directory.

This setup avoids symlinks and keeps files exactly where programs expect them.

How It Works

This repo uses a bare Git repository located at:

`~/.dotfiles`


The working tree is the home directory:

`$HOME`


Git commands are run with:

`--git-dir=$HOME/.dotfiles --work-tree=$HOME`


This allows version control of files in $HOME without moving them into a separate directory.

An alias is used to simplify commands:

`alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'`


All dotfile operations are performed using dot instead of git.

Tracked Configurations

Examples:

~/.config/fish

~/.config/tmux

~/.config/sesh


Machine-specific files, secrets, and cache directories are intentionally excluded.

Installation (Fresh System Setup)
1. Clone the bare repository
git clone --bare <repo-url> $HOME/.dotfiles

2. Define the dot alias

For Fish (~/.config/fish/config.fish):

`alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'`


Reload shell:

`exec fish`

3. Hide untracked files
`dot config --local status.showUntrackedFiles no`

4. Checkout tracked files
`dot checkout`
