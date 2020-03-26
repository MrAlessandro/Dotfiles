# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# set XDG config directory
if [ -d "$HOME/.config" ] ; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

# set XDG cache directory
if [ -d "$HOME/.cache" ] ; then
    export XDG_CACHE_HOME="$HOME/.cache"
fi

# set XDG data directory
if [ -d "$HOME/.local/share" ] ; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi

# set XDG data directories
if [ -d "/usr/share" ] ; then
    export XDG_DATA_DIRS="/usr/share"
fi
if [ -d "/usr/local/share" ] ; then
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/local/share"
fi

# set XDG system wide config dir
if [ -d "/etc/xdg" ] ; then
    export XDG_CONFIG_DIRS="/etc/xdg"
fi

# set bash history file
if [ -d "$XDG_CONFIG_HOME/bash" ] ; then
    export HISTFILE="$XDG_CONFIG_HOME/bash/history"
fi

# set less history file
if [ -d "$XDG_CONFIG_HOME/less" ] ; then
    export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
fi

# set Jet Brains IDE properties directories
#export IDEA_PROPERTIES="$XDG_CONFIG_HOME/IntelliJIdea"
#export CLION_PROPERTIES="$XDG_CONFIG_HOME/CLion"
#export APPCODE_PROPERTIES="$XDG_CONFIG_HOME/AppCode"
#export PYCHARM_PROPERTIES="$XDG_CONFIG_HOME/PyCharm"
#export DATAGRIP_PROPERTIES="$XDG_CONFIG_HOME/DataGrip"
#export STUDIO_PROPERTIES="$XDG_CONFIG_HOME/AndroidStudio"
#export WEBIDE_PROPERTIES="$XDG_CONFIG_HOME/WebIde"
#export PHPSTORM_PROPERTIES="$XDG_CONFIG_HOME/PhpStorm"
#export GOLAND_PROPERTIES="$XDG_CONFIG_HOME/GoLand"
#export RIDER_PROPERTIES="$XDG_CONFIG_HOME/Rider"

# set Gradle user directory
# export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

# Load bashrc file if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
    fi
fi
