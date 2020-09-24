#!/bin/sh

# emacs directory
EMACS_HOME="${HOME}/.emacs.d"

# set Internal Field Separator
IFS=": "
# dotfiles
DOTFILES="env"
DOTFILES="profile:${DOTFILES}"
DOTFILES="zprofile:${DOTFILES}"
DOTFILES="zshrc:${DOTFILES}"
DOTFILES="zlogin:${DOTFILES}"
DOTFILES="bash_profile:${DOTFILES}"
DOTFILES="bash_login:${DOTFILES}"
DOTFILES="bashrc:${DOTFILES}"
DOTFILES="tmux.conf:${DOTFILES}"
	
rm -rf "${EMACS_HOME}"

for DOTFILE in ${DOTFILES}; do
    # check if selected dotfiles exists
    if [ -f "${HOME}/.${DOTFILE}" ] || [ -h "${HOME}/.${DOTFILE}" ]; then
        rm -rf "${HOME}/.${DOTFILE}" 
    fi
done
