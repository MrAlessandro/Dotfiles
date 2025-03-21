# check if colors are supported by current terminal
case "$TERM" in
xterm-color | *-256color) COLOR_PROMPT="YES" ;;
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
# Place the curson at the end of the line when navigating commands history
autoload -U history-search-end
#zle -N history-beginning-search-backward-end history-search-end
#zle -N history-beginning-search-forward-end history-search-end
# Consider actual command line content when navigating commands history with arrow keys
#bindkey "^[[A" history-beginning-search-backward-end # UP
#bindkey "^[[B" history-beginning-search-forward-end # DOWN

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

export NVM_DETECTED=''
export VIRTUAL_ENV_DISABLE_PROMPT=yes

if [ "${COLOR_PROMPT}" = "YES" ]; then
    # Check for active virtualenv
    function virtualenv_info {
        if [[ "${TERM_PROGRAM}" == "vscode" ]]; then
            echo " ";
            return;
        fi
        if [[ -n "${VIRTUAL_ENV}" ]]; then
            echo "%F{blue}($(basename ${VIRTUAL_ENV}))%f "
        fi
    }

    function node_info {
        if [ ! -z "$NVM_DETECTED" ]; then
            echo "${NVM_DETECTED} "
        fi
    }

    function ssh_info {
        if [[ -n "$SSH_CLIENT" ]]; then
            echo "%F{yellow}[ssh>_] %f" # The session is SSH
        fi
    }

    export PS1='$(node_info)$(ssh_info)$(virtualenv_info)%(1j.%F{cyan}%j⚙%f  .)%B%F{green}%n@%m%f:%F{blue}%~%b%f${vcs_info_msg_0_}\$ '
    export RPS1="%(?.%F{green}✔%f.%F{red}✘%f)"
else
    # Check for active virtualenv
    function virtualenv_info {
        if [[ "${TERM_PROGRAM}" == "vscode" ]]; then
            echo " ";
            return;
        fi
        if [[ -n "${VIRTUAL_ENV}" ]]; then
            echo "($(basename ${VIRTUAL_ENV})) "
        fi
    }

    # function node_info {
    #     if [which node &>/dev/null]; then
    #         echo '[Node($(node -v))[ '
    #     fi
    # }

    function ssh_info {
        if [[ -n "$SSH_CLIENT" ]]; then
            echo "[ssh>_] %f" # The session is SSH
        fi
    }

    export PS1='$(ssh_info)$(virtualenv_info)%(1j.%j⚙%  .)%n@%M:%~${vcs_info_msg_0_}\$ '
    export RPS1="%(?.✔.✘)"
fi

# Print a random, interesting, adage
# if command -v fortune >/dev/null; then
#     fortune
# fi

# Special iTerm integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# load aliases definitions if are present
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# # place this after nvm initialization!
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path

  # Check if nvm_find_nvmrc is available
  if ! command -v nvm_find_nvmrc &>/dev/null; then
    return
  fi

  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      if [ "${COLOR_PROMPT}" = "YES" ]; then
        export NVM_DETECTED="%F{red}(⬡!)%f"
      else
        export NVM_DETECTED="(⬡!)"
      fi
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use &>/dev/null
      if [ "${COLOR_PROMPT}" = "YES" ]; then
        export NVM_DETECTED="%F{cyan}(⬡ $(cat "${nvmrc_path}"))%f"
      else
        export NVM_DETECTED="(⬡ $(cat "${nvmrc_path}"))"
      fi
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    nvm use default &>/dev/null
    export NVM_DETECTED=""
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/alessandro/.config/.dart-cli-completion/zsh-config.zsh ]] && . /Users/alessandro/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/alessandro/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/alessandro/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/alessandro/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/alessandro/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/alessandro/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
