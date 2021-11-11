#!/bin/sh
#############################################################
# Set development environment on Linux/macOS quickly.
# Almost taken from: https://github.com/seagle0128/dotfiles/blob/master/install.sh
# Thanks to: Vincent Zhang
# Author: Alessandro Meschi
#############################################################

# operative system
OS="$(uname -s)"
# dotiles dir
DOTFILES_HOME="${HOME}/.dotfiles"
# emacs directory
EMACS_HOME="${HOME}/.emacs.d"
# dofiles backup directory
DOTFILES_BACKUP_DIR="${HOME}/DotfilesBackUp"
# config home
if [ ! -n "${XDG_CONFIG_HOME}" ]; then
  XDG_CONFIG_HOME="${HOME}/.config"
fi
# zsh home
ZSH_HOME="${XDG_CONFIG_HOME}/zsh"
# zsh plugin dir
ZSH_PLUGINS_DIR="${ZSH_HOME}/plugins"
# save current directory
CURRENT_DIRECTORY="$(pwd)"


# set Internal Field Separator
IFS=": "
# dotfiles
DOTFILES="env"
DOTFILES="aliases:${DOTFILES}"
DOTFILES="profile:${DOTFILES}"
DOTFILES="zprofile:${DOTFILES}"
DOTFILES="zshrc:${DOTFILES}"
DOTFILES="zlogin:${DOTFILES}"
DOTFILES="bash_profile:${DOTFILES}"
DOTFILES="bash_login:${DOTFILES}"
DOTFILES="bashrc:${DOTFILES}"
DOTFILES="tmux.conf:${DOTFILES}"

CONFIGDIRS="micro"

# check if stdout is a terminal...
if test -t 1; then

    # see if it supports colors...
    NCOLORS=$(tput colors)

    # set colors
    if command -v tput >/dev/null && test -n "${NCOLORS}" && test "${NCOLORS}" -ge 8; then
        BOLD="$(tput bold)"
        UNDERLINE="$(tput smul)"
        NORMAL="$(tput sgr0)"
        BALCK="$(tput setaf 0)"
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        MAGENTA="$(tput setaf 5)"
        CYAN="$(tput setaf 6)"
        WHITE="$(tput setaf 7)"
    fi
fi


# checking os
printf "%sChecking operative system...%s " "${MAGENTA}" "${NORMAL}"
if [ "${OS}" = "Darwin" ]; then
    printf "%sCOMPATIBLE → macOS %s%s\n" "${BOLD}${GREEN}" "$(sw_vers -productVersion)" "${NORMAL}"
elif [ "${OS}" = "Linux" ]; then
    printf "%sCOMPATIBLE → %s %s%s\n" "${BOLD}${GREEN}" "${OS}" "$(sw_vers -productVersion)" "${NORMAL}"
else
    printf "%sINCOMPATIBLE → %s is not supported by these dotfiles%s\n" "${BOLD}${RED}" "${OS}" "${NORMAL}" 1>&2
    exit 1
fi

# checking root permission
# if [ "$(whoami)" != "root" ]; then
#     printf "%s%sPlease run this script as root or using sudo%s\n" "${BOLD}" "${RED}" "${NORMAL}" 1>&2
#     exit
# fi

# check for package manager
printf "%sChecking for supported package manager...%s " "${MAGENTA}" "${NORMAL}"
PACKAGE_MANAGER=""
if [ "${OS}" = "Darwin" ]; then

    if command -v port >/dev/null; then
        printf "%s%s%s\n" "${BOLD}${GREEN}" "$(command -v port)" "${NORMAL}"
        alias install_package="sudo port install"
        PACKAGE_MANAGER="port"
    elif [ -x "/opt/local/bin/port" ]; then
        # This if-then branch is useful when port is intalled but not in PATH
        printf "%s%s%s\n" "${BOLD}${GREEN}" "/opt/local/bin/port" "${NORMAL}"
        alias install_package="sudo /opt/local/bin/port install"
        PACKAGE_MANAGER="port"
    elif command -v brew >/dev/null; then
        printf "%s%s%s\n" "${BOLD}${GREEN}" "$(command -v brew)" "${NORMAL}"
        alias install_package="brew install"
        PACKAGE_MANAGER="brew"
    else
        printf "%sNOT FOUND → Install MacPorts or brew to get this script works%s\n" "${BOLD}${RED}" "${NORMAL}"
        exit 1
    fi

elif [ "${OS}" = "Linux" ]; then

    if command -v apt-get >/dev/null; then
        printf "%s%s%s\n" "${BOLD}${GREEN}" "$(command -v apt-get)" "${NORMAL}"
        alias install_package="sudo apt-get install"
        PACKAGE_MANAGER="apt"
    else
        printf "%sNOT FOUND → Install apt-get to get this script works%s\n" "${BOLD}${RED}" "${NORMAL}"
        exit 1
    fi

fi

# check for git
printf "%sChecking git...%s " "${MAGENTA}" "${NORMAL}"
if ! command -v git >/dev/null; then
    printf "%sNOT FOUND → Dotfiles require git, intall it and retry%s\n" "${BOLD}${RED}" "${NORMAL}"
    exit 1
fi
printf "%sFOUND%s\n" "${BOLD}${GREEN}" "${NORMAL}"

# move in home directory
cd "${HOME}"

# dotfiles installation
printf "%s\n\t\tDOTFILES INSTALLATION%s\n\n" "${BOLD}${CYAN}" "${NORMAL}"
spinner()
{
    COMMAND_PID=$1 # Process Id of the previous running command
    SPIN='⣷ ⣯ ⣟ ⡿ ⢿ ⣻ ⣽ ⣾'
    printf "⣷"
    while kill -0 "${COMMAND_PID}" 2>/dev/null; do
        for I in $SPIN; do
            printf "\b%s%s%s" "${BLUE}" "${I}" "${NORMAL}"
            sleep .1
        done
    done

    wait "${COMMAND_PID}" # capture exit code
    printf "\b"

    unset COMMAND_PID
    unset SPIN
    unset I

    return $?
}

# cloning dotfiles repository in the home directory
printf "%sCloning dotfiles repository in \"%s\"...%s " "${MAGENTA}" "${DOTFILES_HOME}" "${NORMAL}"
if [ ! -d "${DOTFILES_HOME}" ]; then
    mkdir "${DOTFILES_HOME}"
    git clone --depth 1 "https://github.com/GitMYfault/Dotfiles.git" "${DOTFILES_HOME}" > /dev/null 2>&1 &
    spinner $!
    printf "%sCLONED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
else
    cd "${DOTFILES_HOME}" || exit 1
    git pull --rebase --stat origin master > /dev/null 2>&1 &
    spinner $!
    printf "%sPULLED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
    cd "${OLDPWD}" || exit 1
fi

# ask for backup
BACKUP=""
while [ -z "${BACKUP}" ]; do
    printf "%sDo you want to backup all of your actual dotfiles [y/n]? %s" "${MAGENTA}" "${NORMAL}"
    read -r BACKUP

    case $BACKUP in
        [Yy]* ) BACKUP=0 && break;;
        [Nn]* ) BACKUP=1 && break;;
        * ) BACKUP="" && printf "%sPlease answer yes or no.%s\n" "${BOLD}${RED}" "${NORMAL}";;
    esac
done

# do backup if wanted
if [ "${BACKUP}" = "0" ]; then
    # save actual dotfiles
    printf "%sSaving actual dotfiles in \"%s\"...%s " "${MAGENTA}" "${DOTFILES_BACKUP_DIR}" "${NORMAL}"

    # create backup directory if it does not exist
    if [ ! -d "${DOTFILES_BACKUP_DIR}" ]; then
        mkdir -p "${DOTFILES_BACKUP_DIR}"
    fi

    for DOTFILE in ${DOTFILES}; do
        # check if selected dotfiles exists
        if [ -f "${HOME}/.${DOTFILE}" ]; then
            # copy dotfile in backup directory
            cp -r "${HOME}/.${DOTFILE}" "${DOTFILES_BACKUP_DIR}/${DOTFILE}.backup" >/dev/null 2>&1
        fi
    done

    for CONFIGDIR in ${CONFIGDIRS}; do
   		# check if selected config directory exists
  		if [ -d "${XDG_CONFIG_HOME}/${CONFIGDIR}" ]; then
    			# copy config directory in backup directory
    			cp -r "${XDG_CONFIG_HOME}/${CONFIGDIR}" "${DOTFILES_BACKUP_DIR}/${CONFIGDIR}.backup"
  		fi
   	done

    # saving complete
    printf "%sSAVED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
fi

# remove actual dotfiles
printf "%sRemoving actual dotfiles from home directory ...%s " "${MAGENTA}" "${NORMAL}"
for DOTFILE in ${DOTFILES}; do
    # check if selected dotfiles exists
    if [ -f "${HOME}/.${DOTFILE}" ]; then
        rm -rf "${HOME}/.${DOTFILE}" >/dev/null 2>&1
    fi
done

for CONFIGDIR in ${CONFIGDIRS}; do
    # check if selected config dirextory exists
    if [ -d  "${XDG_CONFIG_HOME}/${CONFIGDIR}" ]; then
        rm -rf "${XDG_CONFIG_HOME}/${CONFIGDIR}" >/dev/null 2>&1
    fi
done
# removing complete
printf "%sREMOVED%s\n" "${BOLD}${GREEN}" "${NORMAL}"

# linking dotfiles in home directory
printf "%sLinking dotfiles in home directory from \"%s\"...%s " "${MAGENTA}" "${DOTFILES_HOME}" "${NORMAL}"
for DOTFILE in ${DOTFILES}; do
    # check if selected dotfiles exists
    if [ -f "${DOTFILES_HOME}/${DOTFILE}" ]; then
        ln -sf "${DOTFILES_HOME}/${DOTFILE}" "${HOME}/.${DOTFILE}" >/dev/null 2>&1
    fi
done

for CONFIGDIR in ${CONFIGDIRS}; do
    # check if selected dotfiles exists
    if [ -d  "${DOTFILES_HOME}/${CONFIGDIR}" ]; then
        ln -sf "${DOTFILES_HOME}/${CONFIGDIR}" "${XDG_CONFIG_HOME}/${CONFIGDIR}" >/dev/null 2>&1
    fi
done
# linking complete
printf "%sLINKED%s\n" "${BOLD}${GREEN}" "${NORMAL}"


printf "%s\n\t\tADDING EXTRA FEATURES%s\n\n" "${BOLD}${CYAN}" "${NORMAL}"
# ask for synthax highlighting installation
ZSH_SINTHAX_HIGHLIGHT_FLAG=""
while [ -z "${ZSH_SINTHAX_HIGHLIGHT_FLAG}" ]; do
    printf "%sDo you want to install zsh synthax highlighting [y/n]? %s" "${MAGENTA}" "${NORMAL}"
    read -r ZSH_SINTHAX_HIGHLIGHT_FLAG

    case $ZSH_SINTHAX_HIGHLIGHT_FLAG in
        [Yy]* ) ZSH_SINTHAX_HIGHLIGHT_FLAG=0 && break;;
        [Nn]* ) ZSH_SINTHAX_HIGHLIGHT_FLAG=1 && break;;
        * ) ZSH_SINTHAX_HIGHLIGHT_FLAG="" && printf "%sPlease answer yes or no.%s\n" "${BOLD}${RED}" "${NORMAL}";;
    esac
done

# install synthax highlighting if wanted
if [ "${ZSH_SINTHAX_HIGHLIGHT_FLAG}" = "0" ]; then
  ZSH_SINTHAX_HIGHLIGHT_DIR="${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting"

  # create zsh plugins dir if it does not exist
  if [ ! -d "${ZSH_PLUGINS_DIR}" ]; then
      mkdir -p "${ZSH_PLUGINS_DIR}" >/dev/null 2>&1
  fi

  printf "%sCloning zsh synthax highlighting repository in \"%s\"...%s " "${MAGENTA}" "${ZSH_SINTHAX_HIGHLIGHT_DIR}" "${NORMAL}"
  if [ ! -d "${ZSH_SINTHAX_HIGHLIGHT_DIR}" ]; then
    git clone --depth 1 "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_SINTHAX_HIGHLIGHT_DIR}" > /dev/null 2>&1 &
    spinner $!
    printf "%sCLONED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
  else
    cd "${ZSH_SINTHAX_HIGHLIGHT_DIR}" || exit 1
    git pull --rebase --stat origin master > /dev/null 2>&1 &
    spinner $!
    printf "%sPULLED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
    cd "${OLDPWD}" || exit 1
  fi
fi


# ask for autosuggestion installation
ZSH_AUTOSUGGESTION_FLAG=""
while [ -z "${ZSH_AUTOSUGGESTION_FLAG}" ]; do
    printf "%sDo you want to install zsh autosuggestion [y/n]? %s" "${MAGENTA}" "${NORMAL}"
    read -r ZSH_AUTOSUGGESTION_FLAG

    case $ZSH_AUTOSUGGESTION_FLAG in
        [Yy]* ) ZSH_AUTOSUGGESTION_FLAG=0 && break;;
        [Nn]* ) ZSH_AUTOSUGGESTION_FLAG=1 && break;;
        * ) ZSH_AUTOSUGGESTION_FLAG="" && printf "%sPlease answer yes or no.%s\n" "${BOLD}${RED}" "${NORMAL}";;
    esac
done

# install autosuggestion if wanted
if [ "${ZSH_AUTOSUGGESTION_FLAG}" = "0" ]; then
  ZSH_AUTOSUGGESTION_DIR="${ZSH_PLUGINS_DIR}/zsh-autosuggestions"

  # create zsh plugins dir if it does not exist
  if [ ! -d "${ZSH_PLUGINS_DIR}" ]; then
      mkdir -p "${ZSH_PLUGINS_DIR}" >/dev/null 2>&1
  fi

  printf "%sCloning zsh autosuggestion repository in \"%s\"...%s " "${MAGENTA}" "${ZSH_AUTOSUGGESTION_DIR}" "${NORMAL}"
  if [ ! -d "${ZSH_AUTOSUGGESTION_DIR}" ]; then
    git clone --depth 1 "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_AUTOSUGGESTION_DIR}" > /dev/null 2>&1 &
    spinner $!
    printf "%sCLONED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
  else
    cd "${ZSH_AUTOSUGGESTION_DIR}" || exit 1
    git pull --rebase --stat origin master > /dev/null 2>&1 &
    spinner $!
    printf "%sPULLED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
    cd "${OLDPWD}" || exit 1
  fi
fi

# ask for micro editor installation
MICRO_EDITOR_FLAG=""
while [ -z "${MICRO_EDITOR_FLAG}" ]; do
    printf "%sDo you want to install micro editor [y/n]? %s" "${MAGENTA}" "${NORMAL}"
    read -r MICRO_EDITOR_FLAG

    case $MICRO_EDITOR_FLAG in
        [Yy]* ) MICRO_EDITOR_FLAG=0 && break;;
        [Nn]* ) MICRO_EDITOR_FLAG=1 && break;;
        * ) MICRO_EDITOR_FLAG="" && printf "%sPlease answer yes or no.%s\n" "${BOLD}${RED}" "${NORMAL}";;
    esac
done

# install micro editor if wanted
if [ "${MICRO_EDITOR_FLAG}" = "0" ]; then

  printf "%sInstalling micro editor...%s " "${MAGENTA}" "${NORMAL}"
  install_package micro > /dev/null 2>&1 &
  spinner $!
  printf "%sINSTALLED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
fi


# ask for Java JDK 8 installation
JAVA_JDK_FLAG=""
while [ -z "${JAVA_JDK_FLAG}" ]; do
    printf "%sDo you want to install Java JDK 8 [y/n]? %s" "${MAGENTA}" "${NORMAL}"
    read -r JAVA_JDK_FLAG

    case $JAVA_JDK_FLAG in
        [Yy]* ) JAVA_JDK_FLAG=0 && break;;
        [Nn]* ) JAVA_JDK_FLAG=1 && break;;
        * ) JAVA_JDK_FLAG="" && printf "%sPlease answer yes or no.%s\n" "${BOLD}${RED}" "${NORMAL}";;
    esac
done

# install micro editor if wanted
if [ "${JAVA_JDK_FLAG}" = "0" ]; then
  printf "%sInstalling Java JDK 8 (can take a while)...%s " "${MAGENTA}" "${NORMAL}"
  JDK_8_PACKAGE_NAME=""
  case $PACKAGE_MANAGER in
    port ) JDK_8_PACKAGE_NAME="openjdk8-temurin" && break;;
    brew ) JDK_8_PACKAGE_NAME="openjdk@8" && break;;
    apt ) JDK_8_PACKAGE_NAME="openjdk-8-jdk" && break;;
  esac
  install_package $JDK_8_PACKAGE_NAME > /dev/null 2>&1 &
  spinner $!
  printf "%sINSTALLED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
fi

# restore previous current directory
cd "${CURRENT_DIRECTORY}"
