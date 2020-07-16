#!/bin/bash
#
# simon's fancy bash prompt.
#
# I try to keep it as fast as possible without passing on all the nice modern
# features we want to have in our prompt nowadays.
#
# This prompt uses timeout, which is not usable for functions, that's the
# reason why this script uses this weird hack at the bottom where this script
# calls itself via PROMPT_COMMAND.
#
# This prompt also tries a second kind of git call to check if it is inside a
# repo. This is to compensate for the git-setup I use in my home-repo for my
# dotfiles.
#
# supported environment variables for configuration:
#
#   PROMPT_COLORS=[true|false]          Enable/disable coloring (default: true)
#
#   PROMPT_CONTAINERS=[true|false]      Enable/disable displaying of active
#                                       environments like chroot, schroot or
#                                       python virtualenv. (default: true)
#
#   PROMPT_GIT=[true|false]             Enable/disable git status in prompt.
#                                       The usual stuff. Brunch name (if not
#                                       master), clean/dirty status, uncommited
#                                       and unpulled stuff, ... (default: true)
#
#   PROMPT_TIMEOUT=[0.1|0.3|1|3|...]    Timeout in seconds. Used for more time
#                                       intensive stuff. For now only the git
#                                       status is using this. (default: 0.1)
#
#   PROMPT_EASTEREGG=[true|false]       Enable/disable easteregg (default: true)
#
#
#
# todo: env var. for utf8
# todo: support devicons
# todo: add fixes from basti
# todo: get rid of pstree depends

function color_exists() {
    [[ "${COLORS[${1:-none}]+isset}" ]]
}

function color_ps1() {
    local color="${1:-none}"
    local msg="${2:-}"
    if ( ${PROMPT_COLORS:-true} ) && color_exists "$color" ; then
        echo -ne "\[${COLORS[$color]}\]${msg:+$msg$( color_ps1 )}"
    else
        echo -ne "$msg"
    fi
}

function prompt_status_git() {
    local gitBranch gitReflogId gitUntracked gitModified gitLastlogId \
          gitRemoteBranchExists gitLastlogId ahead modified untracked \
          ok

    if ( git rev-parse --is-inside-work-tree 2>/dev/null >&2 ) ; then
        gitBranch="$( git symbolic-ref -q --short HEAD )"
        gitReflogId="$( git reflog --pretty=format:'%h' -1 )"
        gitUntracked="$( git ls-files --other --exclude-standard --directory | egrep -v '/$' | head -n 1 )"
        gitModified="$( git ls-files -m | head -n 1 )"
        gitRemoteBranchExists="$( git branch -r | grep "origin/${gitBranch}$" )"
    elif ( git --git-dir=$HOME/.cfg/ --work-tree=$HOME rev-parse --is-inside-work-tree 2>/dev/null >&2 ) ; then
        gitBranch="$( git --git-dir=$HOME/.cfg/ --work-tree=$HOME symbolic-ref -q --short HEAD )"
        gitReflogId="$( git --git-dir=$HOME/.cfg/ --work-tree=$HOME reflog --pretty=format:'%h' -1 )"
        gitUntracked="$( git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files $HOME --other --exclude-standard --directory | egrep -v '/$' | head -n 1 )"
        gitModified="$( git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files $HOME -m | head -n 1 )"
        gitRemoteBranchExists="$( git --git-dir=$HOME/.cfg/ --work-tree=$HOME branch -r | grep "origin/${gitBranch}$" )"
    else
        return
    fi

    if [[ -n "$gitRemoteBranchExists" ]] ; then
        gitLastlogId="$( LANG=C git log --pretty=format:'%h' origin/"${gitBranch}" -1 )"

        if [[ "${gitReflogId}" != "${gitLastlogId}" ]] ; then
            ahead="$( color_ps1 yellow "↑" )"
        fi
    else
        ahead="$( color_ps1 yellow "?" )"
    fi

    if [[ -n "${gitModified}" ]] ; then
        modified="$( color_ps1 red "⚡" )"
    fi

    if [[ -n "${gitUntracked}" ]] ; then
        untracked="$( color_ps1 red "?" )"
    fi

    if [[ "${gitBranch}" == 'master' ]] || [[ "${gitBranch}" == 'main' ]] ; then
        gitBranch=""
    else
        gitBranch="$gitBranch "
    fi

    if [[ -z "${ahead}" ]] && [[ -z "${modified}" ]] ; then
        ok="$( color_ps1 green "♥" )"
    fi
    echo " (${gitBranch}${ok}${modified}${ahead}${untracked})"
}

function es_prompt() {
    local lastret=$?
    local boolean=(true false)
    local colors scriptname PS1prompt PS1error PS1user PS1host PS1path PS1git \
          PS1chroot PS1schroot PS1virtualenv PS1container

    local IS_SUDO IS_ROOT IS_UID0 IS_SSH
    IS_SUDO=$( pstree -s "$$" | grep -qi 'sudo' ; echo "${boolean[$?]}" )
    IS_ROOT=$( [[ "$( id -u )" == 0 ]] && ! ${IS_SUDO} ; echo "${boolean[$?]}" )
    IS_UID0=$( ${IS_SUDO} || ${IS_ROOT} ; echo "${boolean[$?]}" )
    IS_SSH=$( [[ -n "${SSH_CLIENT}${SSH_CONNECTION}${SSH_TTY}" ]] || pstree -s "$$" | grep -qi 'sshd' ; echo "${boolean[$?]}" )

    colors="${1:-true}"
    scriptname="$( readlink -f "$HOME/${BASH_SOURCE[0]}" )"
    PS1error=$( [[ ${lastret} -gt 0 ]] && echo "${lastret}" )
    PS1prompt=" > "
    PS1user="${SUDO_USER:-$USER}"
    PS1host="\h"
    PS1path="\w"
    PS1error=${PS1error:+[$( color_ps1 red "$PS1error" )] }
    PS1path=${PS1path:+$( color_ps1 black )$( color_ps1 white_background "$PS1path" )}

    if ${IS_UID0} ; then
        PS1user="${PS1user:+$( color_ps1 red "${PS1user}" )}"
    fi

    if ${IS_SSH} ; then
        PS1host="${PS1host:+$( color_ps1 red "${PS1host}" )}"
    fi

    if ( ${PROMPT_CONTAINERS:-true} ) ; then
        PS1schroot=${SCHROOT_CHROOT_NAME:+($( color_ps1 red "schroot:" )$SCHROOT_CHROOT_NAME)}
        PS1chroot=${debian_chroot:+($( color_ps1 red "chroot:" )$debian_chroot)}
        PS1virtualenv=${VIRTUAL_ENV:+($( color_ps1 red "venv:" )$VIRTUAL_ENV)}
        PS1container="${PS1schroot:-$PS1chroot}${PS1virtualenv}"
        PS1container="${PS1container:+ $PS1container}"
    fi

    if ${PROMPT_GIT:-true} && [[ -x "$scriptname" ]] && which timeout >/dev/null ; then
        local gitret

        PS1git=$( LANG=C timeout "${PROMPT_TIMEOUT:-0.1}" "$scriptname" "$colors" )
        gitret=$?

        if [[ $gitret -eq 124 ]] ; then
            PS1git=" ($( color_ps1 red "git slow" ))"
        fi
    fi

    if ${PROMPT_EASTEREGG:-true} && ${PROMPT_COLORS:-true} && [[ "$( date +%m%d )" == "0401" ]] ; then
        PS1user='つ\[\033[31m\](\[\033[5m\]♥\[\033[0m\033[31m\])\[\033[0m\]_♥つ'
    fi

    PS1="${PS1error}${PS1user}@${PS1host} ${PS1path}${PS1container}${PS1git}${PS1prompt}"
}

declare -g -A COLORS
COLORS[none]="\e[0m"
COLORS[black]="\e[0;30m"
COLORS[red]="\e[0;31m"
COLORS[green]="\e[0;32m"
COLORS[yellow]="\e[0;33m"
COLORS[white_background]="\e[47m"

# shellcheck disable=2154
if [[ "${0}" != '-bash' ]] && [[ "$( readlink -f "${0}" )" == "$( readlink -f "${BASH_SOURCE[0]}" )" ]] ; then
    prompt_status_git "${1:-true}"
else
    # called by source - export PROMPT_COMMAND git prompt if not already set
    if ! ( echo "$PROMPT_COMMAND" | grep -q "es_prompt" ) ; then
        export PROMPT_COMMAND="es_prompt${PROMPT_COMMAND:+ ; ${PROMPT_COMMAND}}"
    fi
fi
