function fish_prompt
        
    # Show current directory (basename only for brevity)
    set_color blue
    echo -n (prompt_pwd)
    set_color normal
    
    # Show git branch if in a repo (optional, remove if too much)
    if git rev-parse --is-inside-work-tree &>/dev/null
        set_color yellow
        echo -n ' ('(git branch --show-current 2>/dev/null)')'
        set_color normal
    end
    
    # Prompt character
    echo -n ' > '
end


# Remove right prompt (default shows command duration)
function fish_right_prompt
end

zoxide init fish --cmd cd | source

# Keybinding: Ctrl+a (outside tmux) or Ctrl+a Ctrl+a (inside tmux)
function sesh-sessions
    sesh connect (
        sesh list -i | fzf-tmux -p 55%,60% \
            --no-sort --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -i)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list -i)'
    )
end

# Bind Ctrl+a to sesh when outside tmux
if status is-interactive
    and not set -q TMUX
    bind \ca 'sesh-sessions'
end

if status is-interactive
    and not set -q TMUX
    and not set -q SSH_CONNECTION
    # Use sesh to connect to last session or create new one
    sesh connect (sesh list -t | head -n1) 2>/dev/null; or tmux new-session -s main
end


alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias fishconfig='$EDITOR ~/.config/fish/config.fish'
alias labwcconfig='$EDITOR ~/.config/labwc/rc.xml'

# ========== ENVIRONMENT VARIABLES ==========
# Set your preferred editor
set -gx EDITOR vim  # Change to nvim, vim, or whatever you prefer

# Add local bin to PATH if it exists
if test -d ~/.local/bin
    fish_add_path ~/.local/bin
end

set -g fish_greeting
