# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, do not do anything
case $- in
    *i*) ;;
      *) return;;
esac

# append to the history file, don't overwrite it
shopt -s histappend

# check if colors are supported by current terminal
case "$TERM" in
    xterm-color|*-256color) COLOR_PROMPT="YES";;
esac

function set_prompt
{
    local EXIT="$?" # store current exit code
    local JOBS="$(jobs | wc -l | xargs)" # store background jobs amount
    local PYTHON_VIRTUALENV=""

    # determine active git branch.
    function parse_git_branch
    {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    }

    #----------------------------------------------------------------------------#
    # Bash text colour specification:  \e[<STYLE>;<COLOUR>m
    # (Note: \e = \033 (oct) = \x1b (hex) = 27 (dec) = "Escape")
    # Styles:  0=normal, 1=bold, 2=dimmed, 4=underlined, 7=highlighted
    # Colours: 31=red, 32=green, 33=yellow, 34=blue, 35=purple, 36=cyan, 37=white
    #----------------------------------------------------------------------------#

    # define colors
    local RED='\[\033[0;31m\]' # Red
    local GREEN='\[\033[0;32m\]' # Green
    local YELLOW='\[\033[0;33m\]' # Yellow
    local BLUE='\[\033[0;34m\]' # Blue
    local PURPLE='\[\033[0;35m\]' # Purple
    local CYAN='\[\033[0;36m\]' # Cyan

    local BOLD='\[\033[1m\]' # Bold
    local BOLD_RED='\[\033[1;31m\]' # Bold red
    local BOLD_GREEN='\[\033[1;32m\]' # Bold green
    local BOLD_YELLOW='\[\033[1;33m\]' # Bold yellow
    local BOLD_BLUE='\[\033[1;34m\]' # Bold blue
    local BOLD_PURPLE='\[\033[1;35m\]' # Bold purple
    local BOLD_CYAN='\[\033[1;36m\]' # Bold cyan

    local RESET="\[\033[00m\]" # Reset

    # Check for colors avaiability in prompt
    if [ "${COLOR_PROMPT}" = "YES" ]; then

        # Check return status
        if [[ $EXIT -eq 0 ]]; then
            RET="${GREEN}✔${RESET}"
        else
            RET="${RED}✘${RESET}"
        fi

        # Check for background jobs
        if [[ $JOBS -ne 0 ]]; then
            JOBS="${BOLD_CYAN}${JOBS}⚙  "
        else
            JOBS=""
        fi

        # Check for active virtualenv
        if [ "${VIRTUAL_ENV}" ]; then
            PYTHON_VIRTUALENV="${BLUE}($(basename "${VIRTUAL_ENV}"))${RESET}"
        fi


        # Check for SSH session
        if [[ -n "$SSH_CLIENT" ]]; then
            SSH_SESSION="${YELLOW}[ssh>_] ${RESET}" # The session is SSH
        fi

        export PS1="${RET} ${SSH_SESSION}${PYTHON_VIRTUALENV}${JOBS}${BOLD_GREEN}\u@\h${RESET}:${BOLD_BLUE}\w${PURPLE}$(parse_git_branch)${RESET}\$ "
    else

        # Check return status
        if [[ $EXIT -eq 0 ]]; then
            RET="✔"
        else
            RET="✘"
        fi

        # Check for background jobs
        if [[ $JOBS -ne 0 ]]; then
            JOBS="${JOBS}⚙  "
        else
            JOBS=""
        fi

        # Check for active virtualenv
        if [ "${VIRTUAL_ENV}" ]; then
            PYTHON_VIRTUALENV="($(basename "${VIRTUAL_ENV}"))"
        fi

        # Check for SSH session
        if [[ -n "$SSH_CLIENT" ]]; then
            SSH_SESSION="[ssh>_] " # The session is SSH
        fi

        export PS1="${RET} ${SSH_SESSION}${PYTHON_VIRTUALENV}${JOBS}\u@\h:\w$(parse_git_branch)\$"
    fi
}
export PROMPT_COMMAND="set_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"


# load bash completion
if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
    . /opt/local/etc/profile.d/bash_completion.sh
fi

# load z command
if [ -f /opt/local/etc/profile.d/z.sh ]; then
    source /opt/local/etc/profile.d/z.sh
fi

# Print a random, interesting, adage
# if command -v fortune >/dev/null; then
#     fortune
# fi


# load aliases definitions if are present
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
