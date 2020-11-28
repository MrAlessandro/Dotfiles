# check if colors are supported by current terminal
case "$TERM" in
    xterm-color|*-256color) COLOR_PROMPT="YES";;
esac

# Load completion initialization function
autoload -Uz compinit
# Initialize completion
compinit

# SESSIONS
# Disable zsh sessions
unsetopt share_history

# HISTORY OPTIONS
# Time stamp the history, and more.
setopt extended_history
# Trim duplicated commands from the history before trimming unique commands.
setopt hist_expire_dups_first
# If you run the same command multiple times in a row, only add it to the history once.
setopt hist_ignore_dups
# Add commands to the history file as soon as they are run.
setopt inc_append_history
# Time stamp the history, and more.
setopt share_history

# COMPLETION OPTIONS
# Move the cursor to the end of the word after accepting a completion.
setopt auto_menu
# Moves the cursor to the end of the word when completing
unsetopt always_to_end
# The cursor is set to the end of the word if completion is started.
unsetopt complete_in_word
# Use menu selection for completion
zstyle ':completion:*:*:*:*:*' menu select
# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
# Set cache completion results location
zstyle ':completion::complete:*' cache-path "${ZSH_CACHE_DIR}"
# Enable completion results caching
zstyle ':completion::complete:*' use-cache 1
# Enable colors in completion menu
zstyle ':completion:*:*:*:*:*' list-colors ''
# Use menu completion for all completions
zstyle ':completion:*:*:*:*:*' menu select
# Use verbose completions
zstyle ':completion:*' verbose yes
# Use colors
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# PROMPT OPTIONS
# Enable prompt parameters expansion, command substitution and arithmetic expansion
setopt prompt_subst

# Load version control inizialization function
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats " %F{magenta}(%b)%f"
precmd() {
    vcs_info
}

export VIRTUAL_ENV_DISABLE_PROMPT=yes

if [ "${COLOR_PROMPT}" = "YES" ]; then
    # Check for active virtualenv
    function virtualenv_info {
        if [ "${VIRTUAL_ENV}" ]; then
            echo "%F{blue}($(basename ${VIRTUAL_ENV}))%f "
        fi
    }

    export PS1='$(virtualenv_info)%(1j.%F{cyan}%j⚙%f  .)%B%F{green}%n@%M%f:%F{blue}%~%b%f${vcs_info_msg_0_}\$ '
    export RPS1="%(?.%F{green}✔%f.%F{red}✘%f)"
else
    # Check for active virtualenv
    function virtualenv_info {
        if [ "${VIRTUAL_ENV}" ]; then
            echo "($(basename ${VIRTUAL_ENV})) "
        fi
    }

    export PS1='$(virtualenv_info)%(1j.%j⚙%  .)%n@%M:%~${vcs_info_msg_0_}\$ '
    export RPS1="%(?.✔.✘)"
fi

# load aliases definitions if are present
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Print a random, interesting, adage
if command -v fortune >/dev/null; then
    fortune
fi
