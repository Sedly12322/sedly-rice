# Sedly-Rice .zshrc
([ -f "$HOME/.cache/wal/sequences" ] && cat "$HOME/.cache/wal/sequences" 2>/dev/null &)

# Starship prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Fetch system information
if [ -x "$HOME/.config/fastfetch/fastfetch.sh" ]; then
    "$HOME/.config/fastfetch/fastfetch.sh"
elif command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

# Zsh Plugins (Arch Linux /usr/share/zsh/plugins)
for plugin in \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh \
    /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh \
    /usr/share/zsh/plugins/zsh-auto-notify/auto-notify.plugin.zsh \
    /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh; do
    [ -f "$plugin" ] && source "$plugin"
done

# Zsh Auto-Suggestions styling
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#696969,bold"
HISTSIZE=10000            # Maximum events for internal history
SAVEHIST=10000            # Maximum events in history file
HISTDIR="$HOME/.cache/zsh" # History directory
HISTFILE="$HISTDIR/history" # History filepath
mkdir -p "$HISTDIR"
touch "$HISTDIR/history"

# Zsh Tab Completion
autoload -U compinit
compinit

# Zsh Substring History Search keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Aliases
if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd'
    alias ll='lsd -l'
    alias la='lsd -la'
else
    alias ls='ls --color=auto'
    alias ll='ls -lh'
    alias la='ls -lah'
fi

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

TRAPUSR1() {
    fastfetch_refresh
}

# Editor helpers
function code() {
    /bin/code "$@" && exit
}
function v() {
    if command -v neovide >/dev/null 2>&1; then
        neovide --fork "$@" && exit
    elif command -v nvim >/dev/null 2>&1; then
        nvim "$@"
    else
        vim "$@"
    fi
}

# Utilities
alias logout='hyprctl dispatch exit'

# FZF integration
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

# Android SDK
if [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
    export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
fi

# Local bin path
export PATH="$HOME/.local/bin:$PATH"

# Custom local overrides (not tracked in git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
