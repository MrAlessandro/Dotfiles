#!/bin/sh
#############################################################
# Set development environment on Linux/macOS quickly.
# Almost taken from: https://github.com/seagle0128/dotfiles/blob/master/install.sh
# Thanks to :Vincent Zhang
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
if [ "${OS}" = "Darwin" ]; then

    if command -v port >/dev/null; then
        printf "%s%s%s\n" "${BOLD}${GREEN}" "$(command -v port)" "${NORMAL}"
        alias install_package="sudo port install"
    elif command -v brew >/dev/null; then
        printf "%s%s%s\n" "${BOLD}${GREEN}" "$(command -v brew)" "${NORMAL}"
        alias install_package="brew install"
    else
        printf "%sNOT FOUND → Install MacPorts or brew to get this script works%s\n" "${BOLD}${RED}" "${NORMAL}"
        exit 1
    fi

elif [ "${OS}" = "Linux" ]; then

    if command -v apt-get >/dev/null; then
        printf "%s%s%s\n" "${BOLD}${GREEN}" "$(command -v apt-get)" "${NORMAL}"
        alias install_package="sudo apt-get install"
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
# linking complete
printf "%sLINKED%s\n" "${BOLD}${GREEN}" "${NORMAL}"


# cloning MYmacs repository in the home directory
# printf "%sCloning MYmacs repository in \"%s\"...%s " "${MAGENTA}" "${EMACS_HOME}" "${NORMAL}"
# if [ ! -d "${EMACS_HOME}" ]; then
#     mkdir "${EMACS_HOME}"
#     git clone --depth 1 "https://github.com/GitMYfault/MYmacs.git" "${EMACS_HOME}" > /dev/null 2>&1 &
#     spinner $!
#     printf "%sCLONED%s\n" "${BOLD}${GREEN}" "${NORMAL}"
# else
#     cd "${EMACS_HOME}" || exit 1
#     git pull --rebase --stat origin master > /dev/null 2>&1 &
#     spinner $!
#     cd - || exit 1
# fi
