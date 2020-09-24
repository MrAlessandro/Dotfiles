# ~/.bash_profile: executed by bash for login shells.

# Load common environment setup
if [ -f "${HOME}/.env" ]; then
    . "${HOME}/.env"
fi

# Set history file
export HISTFILE=$HOME/.bash_history

# Disable bash sessions
export SHELL_SESSION_HISTORY=0

# Include .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
	. "${HOME}/.bashrc"
fi