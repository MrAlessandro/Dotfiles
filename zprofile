# ~/.zprofile: executed by zsh for login shells.

# Load common environment setup
if [ -f "${HOME}/.env" ]; then
    . "${HOME}/.env"
fi

# Set history file
export HISTFILE=$HOME/.zsh_history

# Set zsh cache directory
if [ -n "$XDG_CONFIG_HOME" ]; then
	export ZSH_CACHE_DIR="${XDG_CONFIG_HOME}/zsh_cache"
else
	export ZSH_CACHE_DIR="${HOME}/.config/zsh_cache"
fi
# Create it if it does not exist
if [ ! -d "${ZSH_CACHE_DIR}" ]; then
    mkdir -p "${ZSH_CACHE_DIR}" >/dev/null 2>&1
fi

