#!/bin/bash

# Variables
DOTFILES=$HOME/.dotfiles
EMACSD=$HOME/.emacs.d
FZF=$HOME/.fzf
TMUX=$HOME/.tmux

# Get OS informatio
OS=`uname -s`
OSREV=`uname -r`
OSARCH=`uname -m`

is_mac()
{
    [ "$OS" = "Darwin" ]
}

is_cygwin()
{
    [ "$OSTYPE" = "cygwin" ]
}

is_linux()
{
    [ "$OS" = "Linux" ]
}

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if command -v tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
fi

# Dotfiles
printf "${BLUE} ➜  Installing Dotfiles...${NORMAL}\n"

cp -n $DOTFILES/.tmux.conf $HOME/.tmux.conf
