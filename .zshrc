# ==============================================================================
#   Sedly-Rice .zshrc
#   High-performance Zsh configuration with Starship, FZF, and Material 3 colors
# ==============================================================================

# Fastfetch & Wal color escape sequences
([ -f "$HOME/.cache/wal/sequences" ] && cat "$HOME/.cache/wal/sequences" 2>/dev/null &)

# Environment & Paths
export PATH="$HOME/.local/bin:$PATH"
if [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
    export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
fi

# History configuration
HISTDIR="$HOME/.cache/zsh"
HISTFILE="$HISTDIR/history"
HISTSIZE=50000
SAVEHIST=50000
mkdir -p "$HISTDIR"
touch "$HISTFILE" 2>/dev/null || true

setopt INC_APPEND_HISTORY        # Write to history file immediately
setopt SHARE_HISTORY             # Share history across running shells
setopt HIST_IGNORE_ALL_DUPS      # Don't record dupes
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_VERIFY               # Don't execute immediately upon history expansion
setopt AUTO_CD                   # Type directory name to cd into it

# Starship Prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Fastfetch banner on startup
if [[ -o interactive ]] && [ -z "$VIRTUAL_ENV" ]; then
    if [ -x "$HOME/.config/fastfetch/fastfetch.sh" ]; then
        "$HOME/.config/fastfetch/fastfetch.sh"
    elif command -v fastfetch >/dev/null 2>&1; then
        fastfetch
    fi
fi

# Tab Completion Initialization (MUST be before fzf-tab)
autoload -U compinit
compinit -d "$HISTDIR/zcompdump-$ZSH_VERSION"

# Zsh Plugins (Arch Linux /usr/share/zsh/plugins)
# 1. fzf-tab (Loaded right after compinit)
[ -f /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh ] && source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh

# 2. General utility plugins
for plugin in \
    /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh \
    /usr/share/zsh/plugins/zsh-auto-notify/auto-notify.plugin.zsh \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh; do
    [ -f "$plugin" ] && source "$plugin"
done

# 3. Syntax highlighting (MUST be sourced LAST)
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Plugin configurations
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#696969,bold"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# FZF Integration & Previews
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)

    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
    fi

    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border rounded --prompt='❯ ' --pointer='▶' --marker='✔ '"

    if command -v bat >/dev/null 2>&1; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}'"
    fi

    # fzf-tab preview styling
    if command -v eza >/dev/null 2>&1; then
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
    fi
    zstyle ':fzf-tab:*' switch-group ',' '.'
fi

# Zoxide Directory Jumper
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
# Modern ls / directory listings
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --git --group-directories-first'
    alias la='eza -la --icons --git --group-directories-first'
    alias lt='eza --tree --level=2 --icons --group-directories-first'
elif command -v lsd >/dev/null 2>&1; then
    alias ls='lsd --group-directories-first'
    alias ll='lsd -l --group-directories-first'
    alias la='lsd -la --group-directories-first'
    alias lt='lsd --tree --depth=2'
else
    alias ls='ls --color=auto'
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# Bat for syntax highlighted cat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# Fastfetch shortcut & keybind (Ctrl+F)
fastfetch_refresh() {
    clear
    if [ -x "$HOME/.config/fastfetch/fastfetch.sh" ]; then
        "$HOME/.config/fastfetch/fastfetch.sh"
    elif command -v fastfetch >/dev/null 2>&1; then
        fastfetch
    fi
    if zle; then
        echo
        zle redisplay
    fi
}
alias f=fastfetch_refresh
zle -N fastfetch_refresh
bindkey '^F' fastfetch_refresh
TRAPUSR1() { fastfetch_refresh; }

# Quick directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Colorized defaults
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# Git shortcuts
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# Editors
function code() {
    if command -v /bin/code >/dev/null 2>&1; then
        /bin/code "$@"
    else
        command code "$@"
    fi
}

function v() {
    if command -v neovide >/dev/null 2>&1; then
        neovide --fork "$@"
    elif command -v nvim >/dev/null 2>&1; then
        nvim "$@"
    else
        vim "$@"
    fi
}

# Utilities & session
alias logout='hyprctl dispatch exit'

# Custom local overrides (not tracked in git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
