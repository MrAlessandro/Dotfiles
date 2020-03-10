#!/bin/sh
#############################################################
# Set development environment on Linux/macOS quickly.
# Almost taken from: https://github.com/seagle0128/dotfiles/blob/master/install.sh
# Thanks to :Vincent Zhang
# Author: Alessandro Meschi
#############################################################

# Variables
DOTFILES=$HOME/.dotfiles
EMACSD=$HOME/.emacs.d
FZF=$HOME/.fzf
TMUX=$HOME/.tmux.conf
BASH=$HOME/.bashrc
PROFILE=$HOME/.profile
ALIASES=$HOME/.bash_aliases

# Get OS informatio
OS=$(uname -s)

# Only enable exit-on-error after the non-critical colorization stuff,
# which may fail on systems lacking tput or terminfo
# set -e

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
    NORMAL="$(tput sgr0)"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    NORMAL=""
fi

# Check git
command -v git >/dev/null 2>&1 || {
    echo "${RED}Error: git is not installed${NORMAL}" >&2
    exit 1
}

# Check curl
command -v curl >/dev/null 2>&1 ||
{
    echo "${RED}Error: curl is not installed${NORMAL}" >&2
    exit 1
}

# Sync repository
sync_repo()
{
    repo_uri="$1"
    repo_path="$2"
    repo_branch="$3"

    if [ -z "$repo_branch" ]; then
        repo_branch="master"
    fi

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone --depth 1 --branch $repo_branch "https://github.com/$repo_uri.git" "$repo_path"
    else
        cd "$repo_path" && git pull --rebase --stat origin $repo_branch; cd - >/dev/null || exit 1
    fi
}

is_mac()
{
    [ "$OS" = "Darwin" ]
}

is_linux()
{
    [ "$OS" = "Linux" ]
}

is_debian()
{
    command -v apt >/dev/null 2>&1 || command -v apt-get >/dev/null 2>&1
}

is_arch()
{
    command -v yay >/dev/null 2>&1 || command -v pacman >/dev/null 2>&1
}

sync_brew_package()
{
    if ! command -v brew >/dev/null 2>&1; then
        echo "${RED}Error: brew is not found${NORMAL}" >&2
        return 1
    fi

    if ! command -v "${1}" >/dev/null 2>&1; then
        brew install "${1}" >/dev/null
    else
        brew upgrade "${1}" >/dev/null
    fi
}

sync_apt_package()
{
    if command -v apt >/dev/null 2>&1; then
        sudo apt upgrade -y "${1}" >/dev/null
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get upgrade -y "${1}" >/dev/null
    else
        echo "${RED}Error: apt and apt-get are not found${NORMAL}" >&2
        return 1
    fi
}

sync_arch_package()
{
    if command -v yay >/dev/null F; then
        yay -Su --noconfirm "${1}" >/dev/null
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Su --noconfirm "${1}" >/dev/null
    else
        echo "${RED}Error: pacman and yay are not found${NORMAL}" >&2
        return 1
    fi
}

# Clean all configurations
clean_dotfiles()
{
    confs=".bashrc
       .profile
       .bash_profile
       .bash_login
       .bash_aliases
       .tmux.conf"

    for c in ${confs}; do
        [ -f "$HOME"/"${c}" ] && mv "$HOME"/"${c}" "$HOME"/"${c}".bak
    done

    [ -d "$EMACSD" ] && mv "$EMACSD" "$EMACSD".bak

    rm -rf "$TMUX" "$FZF" "$DOTFILES" "$BASH" "$PROFILE" "$ALIASES"
}

YES=0
NO=1

promote_yn()
{
        printf "%s ➜  %s%s [y/N]: " "${YELLOW}" "${1}" "${NORMAL}"

        eval "${2}"=$NO
        read -r yn

        case $yn in
                [Yy]* )    eval "${2}"=$YES;;
                [Nn]*|'' ) eval "${2}"=$NO;;
                * )        eval "${2}"=$NO;;
        esac
}

# Create default configurations directories
printf "%s ➜  Creating default configurations folders...%s" "${BLUE}" "${NORMAL}"
mkdir -p "$HOME"/.config >/dev/null 2>&1
mkdir -p "$HOME"/.config/bash >/dev/null 2>&1
mkdir -p "$HOME"/.config/bash/completions >/dev/null 2>&1
mkdir -p "$HOME"/.config/less >/dev/null 2>&1
mkdir -p "$HOME"/.config/tmux >/dev/null 2>&1
mkdir -p "$HOME"/.config/tmux/plugins >/dev/null 2>&1
mkdir -p "$HOME"/.cache >/dev/null 2>&1
printf "%sCREATED%s\n" "${GREEN}" "${NORMAL}"


# Reset configurations
if [ -d "$TMUX" ] || [ -f "$FZF" ] || [ -d "$EMACSD" ] || [ -f "$BASH" ] || [ -f "$PROFILE" ] || [ -f "$ALIASES" ]; then
        continue=$NO
        promote_yn "Do you want to reset all configurations? [y/N]: " "continue"

        if [ "$continue" -eq $YES ]; then
                clean_dotfiles
        fi
fi

# Brew
if is_mac; then
        if ! command -v brew >/dev/null 2>&1; then
                printf "%s ➜  Installing Homebrew...%s" "${BLUE}" "${NORMAL}"

                # Install homebrew
                /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

                printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"
        fi
fi

# Installing dotfiles
printf "%s ➜  Installing Dotfiles...%s" "${BLUE}" "${NORMAL}"
sync_repo noMYfault/Dotfiles "$DOTFILES"
# Make this installation file executable
chmod +x "$DOTFILES"/install.sh
# Link dotfiles from repo directory to the home
ln -sf "$DOTFILES"/bashrc "$BASH"
ln -sf "$DOTFILES"/profile "$PROFILE"
ln -sf "$DOTFILES"/bash_aliases "$ALIASES"
ln -sf "$DOTFILES"/tmux.conf "$TMUX"
ln -sf "$DOTFILES"/git-completion.bash "$HOME/.config/bash/completions/"
printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"

# Install bash completion user local
if [ ! -e "$HOME/.config/bash/completions/bash-completion/" ]; then
    printf "%s ➜  Installing bash completion...%s" "${BLUE}" "${NORMAL}"
    sync_repo scop/bash-completion "$HOME/.config/bash/completions/bash-completion"
    printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"
fi

# Installing emacs
command -v emacs >/dev/null 2>&1 ||
{
        printf "%s ➜  Installing emacs...%s" "${BLUE}" "${NORMAL}"

        if is_mac; then
                sync_brew_package emacs
        elif is_linux; then
                if is_arch; then
                        sync_arch_package emacs
                elif is_debian; then
                        sync_apt_package emacs
                fi
        fi

        printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"
}

printf "%s ➜  Retrieving MYmacs configuration...%s" "${BLUE}" "${NORMAL}"
sync_repo noMYfault/MYmacs "$EMACSD"
printf "%sRETRIEVED%s\n" "${GREEN}" "${NORMAL}"

# Tmux
command -v tmux >/dev/null 2>&1 ||
{
        printf "%s ➜  Installing tmux...%s" "${BLUE}" "${NORMAL}"

        if is_mac; then
                sync_brew_package tmux
        elif is_linux; then
                if is_arch; then
                        sync_arch_package tmux
                elif is_debian; then
                        sync_apt_package tmux
                fi
        fi

        printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"

        printf "%s ➜  Installing tmux plugin manager...%s" "${BLUE}" "${NORMAL}"
        sync_repo tmux-plugins/tpm "$HOME"/.config/tmux
        printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"

}


# Ripgrep
command -v rg >/dev/null 2>&1 ||
{
        printf "%s ➜  Installing ripgrep (rg)...%s" "${BLUE}" "${NORMAL}"

        if is_mac; then
                sync_brew_package ripgrep
        elif is_linux; then
                if is_arch; then
                        sync_arch_package ripgrep
                elif is_debian; then
                        sync_apt_package ripgrep
                fi
        fi

        printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"
}



# BAT
command -v bat >/dev/null 2>&1 ||
{
        printf "%s ➜  Installing BAT...%s" "${BLUE}" "${NORMAL}"

        if is_mac; then
                sync_brew_package bat
        elif is_linux; then
                if is_arch; then
                        sync_arch_package bat
                elif is_debian; then
                        sync_apt_package bat
                fi
        fi

        printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"
}

# FD
command -v bat >/dev/null 2>&1 ||
{
        printf "%s ➜  Installing FD...%s" "${BLUE}" "${NORMAL}"

        if is_mac; then
            sync_brew_package fd
        elif is_linux; then
                if is_arch; then
                        sync_arch_package fd
                elif is_debian; then
                        sync_apt_package fd-find
                fi
        fi

        printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"
}

# FZF
command -v bat >/dev/null 2>&1 ||
{
        printf "%s ➜  Installing FZF...%s" "${BLUE}" "${NORMAL}"

        if is_mac; then
            sync_brew_package fzf
        elif is_linux; then
            if is_arch; then
                    sync_arch_package fzf
                elif is_debian; then
                        sync_apt_package fzf
                fi
        fi

        printf "%sINSTALLED%s\n" "${GREEN}" "${NORMAL}"
}

printf "Done. Enjoy new dotfiles!\n"
