# ~/.zprofile: executed by zsh for login shells.

# Load common environment setup
if [ -f "${HOME}/.env" ]; then
  . "${HOME}/.env"
fi

# Set history file
export HISTFILE=$HOME/.zsh_history

# Set zsh home directory
if [ -n "${XDG_CONFIG_HOME}" ]; then
  export ZSH_HOME="${XDG_CONFIG_HOME}/zsh"
else
  export ZSH_HOME="${HOME}/.config/zsh"
fi
# Create it if it does not exist
if [ ! -d "${ZSH_HOME}" ]; then
  mkdir -p "${ZSH_HOME}" >/dev/null 2>&1
fi

# Set zsh cache directory
export ZSH_CACHE_DIR="${ZSH_HOME}/zsh_cache"
# Create it if it does not exist
if [ ! -d "${ZSH_CACHE_DIR}" ]; then
  mkdir -p "${ZSH_CACHE_DIR}" >/dev/null 2>&1
fi

# Set zsh cache directory
export ZSH_PLUGINS_DIR="${ZSH_HOME}/plugins"
# Create it if it does not exist
if [ ! -d "${ZSH_PLUGINS_DIR}" ]; then
  mkdir -p "${ZSH_PLUGINS_DIR}" >/dev/null 2>&1
fi

# Load zsh syntax highlighting if present
if [ -f "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Load zsh autosuggestion if present
if [ -f "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
