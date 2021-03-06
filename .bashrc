#!/bin/bash
#
# ~/.bashrc: Simons main .bashrc
#
# This file mostly builds my $PATH and is used as a loader for further configs.
#
# It will check a bunch of directories (listed in $check_directories) for
# .bin/, bin/ or BIN/ directories and adds these to the path if available.
#
# The same directories (listed in $check_directories) will be checked
# afterwards for .bashrc and bashrc files and files in bashrc.d/ and
# .bashrc.d/ subdirectories. These will be all sourced one after another.
#
# If you are interested in my real bash config, please refer to the
# reposioties README[1] or just have a look around in .bashrc.d/[2].
#
# [1] https://github.com/simonschiele/home/tree/master/.repo/README.md
# [2] https://github.com/simonschiele/home/tree/master/.bashrc.d/
#

function debug() {
    if [[ -n "$DEBUG" ]] ; then
        echo "| $1" | tee -a "$HOME"/DEBUG.log >&2
    fi
}

function verify_bash() {
    # test if shell is bash
    if [[ -z "$PS1" ]] || [[ -z "$BASH_VERSION" ]] ; then
        echo "ERROR: shell is not BASH" >&2
        return 1
    fi

    # test if interactive
    if [[ "$-" != *i* ]] ; then
        return 1
    fi

    return 0
}

function already_sourced() {
    # test if "$1" was already loaded

    local src

    for src in "${BASH_SOURCE[@]}" ; do
        [[ "$src" == "$1" ]] && return 0
    done

    return 1
}

function include_once() {
    if already_sourced "$1" ; then
        return 1
    fi

    if [[ -r "$1" ]] ; then
        debug "SOURCE $1"
        # shellcheck disable=SC1090
        if ! source "$1" ; then
            return 1
        fi
    fi
    return 0
}

function include_once_if_existing() {
    if [[ -e "$1" ]] ; then
        include_once "$1"
    fi
}

function bashrc() {
    local i file

    # All entries in 'check_directories' will get checked for a bin/ or .bin/
    # directory. If one is found, it gets added to $PATH.
    # Be aware: ~/ will be always prepended.
    local check_directories=( . .local .vim .config/i3 .private .work )

    # These 'add_bin_directories' get added to $PATH directly if they exist.
    # I use this mostly for small scripts of mine that have their own flat
    # repo and for thirdparty stuff.
    local add_bin_directories=( ~/.bin/vils-ng )

    # check if BASH and interactive or cancel
    verify_bash || return 1

    # source ~/.profile if not already done
    include_once "$HOME"/.profile

    # source system-wide bashrc's if available
    include_once_if_existing /etc/bash.bashrc
    include_once_if_existing /etc/bashrc
    include_once_if_existing /etc/.bashrc

    # build $PATH
    for dir in ${check_directories[*]} ; do
        for i in .bin bin BIN ; do
            if [[ -d "$HOME/$dir"/"$i" ]] ; then
               debug "PATH $HOME/$dir/$i"
               PATH="$HOME/$dir/$i:$PATH"
            fi
        done
    done

    for dir in ${add_bin_directories[*]} ; do
        if [[ -d "$dir" ]] ; then
            PATH="$dir:$PATH"
        fi
    done

    # include .bashrc, bashrc, bashrc.d/*
    for dir in ${check_directories[*]} ; do
        for i in {.,}bashrc {.,}bashrc.d ; do
            for file in "$dir"/"$i"{,/*.sh,/*.bash} ; do
                # skip if file is a directory or exactly this bashrc
                if [[ "$file" == "./.bashrc" ]] || [[ -d "$file" ]] ; then
                    continue
                fi
                include_once "$file"
            done
        done
    done

    unset dir
}

bashrc "$@"
