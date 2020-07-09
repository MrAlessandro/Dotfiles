# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/bin" ] ; then
    export PATH="${HOME}/bin:${PATH}"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/.local/sbin" ] ; then
    export PATH="${HOME}/.local/sbin:${PATH}"
fi
if [ -d "${HOME}/.local/bin" ] ; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

# set PATH so it includes macport's private bin if it exists
if [ -d "/opt/local/bin" ] ; then
    export PATH="/opt/local/sbin:${PATH}"
fi
if [ -d "/opt/local/bin" ] ; then
    export PATH="/opt/local/bin:${PATH}"
fi

# set XDG config directory and create it if does not exist 
export XDG_CONFIG_HOME="${HOME}/.config"
if [ ! -d "${XDG_CONFIG_HOME}" ]; then
    mkdir "${XDG_CONFIG_HOME}" >/dev/null 2>&1
fi

# enable colors
export CLICOLOR=1

# set colors used in ls command
export LSCOLORS=ExFxBxDxCxegedabagacad

# set default editor
if command -v emacs &> /dev/null; then
    export EDITOR="emacs -nw"
fi

# add python binaries to path
if [ -d "${HOME}/Library/Python/3.7/bin" ]; then
    export PATH="${HOME}/Library/Python/3.7/bin:${PATH}"
fi

# check if running bash
if [ -n "$BASH_VERSION" ]; then

    # Disable bash sessions
    export SHELL_SESSION_HISTORY=0

    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
    fi
fi

export PATH="/Library/PostgreSQL/12/bin/:${PATH}"
