#!/bin/bash

function setup_history() {
    shopt -s histappend
    shopt -s cmdhist        # combine multiline

    export HISTSIZE=5000
    export HISTFILESIZE=
    export HISTCONTROL='ignoreboth:erasedups'
    export HISTIGNORE='&:clear:ls:[bf]g:exit:hist:history:tree:w: '
    export HISTTIMEFORMAT='%F %T '

    if [[ -f ~/.history ]] ; then
        mv -f ~/.history{,~}
        mkdir -p ~/.history
        mv -v ~/.history{~,/bash}
    fi

    if [[ ! -d ~/.history ]] && ! mkdir -p ~/.history 2>/dev/null ; then
        echo "[WARNING] Couldn't create '$HOME/.history'" >&2
        return 1
    fi

    local hist histories
    histories=( bash less psql mysql sqlite )
    for hist in ${histories[*]} ; do
        cat ~/.*"${hist}"*h*st* >> ~/.history/"$hist" 2>/dev/null
        rm -f ~/.*"${hist}"*h*st* 2>/dev/null
    done

    export HISTFILE="${HOME}/.history/bash"
    export LESSHISTFILE="${HOME}/.history/less"
    export PSQL_HISTORY="${HOME}/.history/psql"
    export MYSQL_HISTFILE="${HOME}/.history/mysql"
    export SQLITE_HISTFILE="${HOME}/.history/sqlite"

    # sync history between all terminals
    # export PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"
}

function setup_completion() {
    # Sadly the system-wide bash-completion can not get setup here, it breaks
    # completion in a weird way if not sourced from the root of a script (?).
    # Therefore we are doing only custom completion here. To enable the global
    # completion I actually source my global /etc/bash.bashrc from my personal
    # bashrc.

    # include custom completions
    for compl in $HOME/.bash_completion.d/* ; do
        [[ -e $compl ]] && include_once "$compl"
    done

    # completion case insensitive
    bind "set completion-ignore-case on"

    # treat hyphens and underscores as equivalent
    bind "set completion-map-case on"

    # display matches for ambiguous patterns at first tab press
    bind "set show-all-if-ambiguous on"

    # lookup file for hostname completion
    touch $HOME/.history/hosts
    export HOSTFILE="$HOME/.history/hosts"
}

function setup_colors() {
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    which colordiff >/dev/null && alias diff='colordiff'
    which pacman >/dev/null && alias pacman='pacman --color=auto'

    if ( which dircolors >/dev/null ) ; then
        if [[ -r $HOME/.dircolors ]] ; then
            eval "$( dircolors -b ~/.dircolors )"
        else
            eval "$( dircolors -b )"
        fi
    fi

    export GREP_COLOR='7;34'

    export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

    export LESS_TERMCAP_mb=$'\e[01;31m'
    export LESS_TERMCAP_md=$'\e[01;37m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[01;43;37m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[01;32m'
}

function setup_ssh() {
    # siehe auch:
    # https://gist.github.com/octocat/2a6851cde24cdaf4b85b 

    ### Test whether you have a running agent.
    #$ ssh-add -l >& /dev/null; [ $? = 2 ] && echo no-agent
    #no-agent
    ### If not, start one.
    #$ eval $(ssh-agent)
    ### Now, add your key to the agent.
    #$ ssh-add

    if [ -n "$SSH_AGENT_PID" ] && ps "$SSH_AGENT_PID" 2>/dev/null >&2 ; then
        # found, running and exported - all fine
        echo -n
    elif ( pgrep -u "${SUDO_USER:-$USER}" ssh-agent >/dev/null ) ; then
        # reuse already running agent for active user
        SSH_AGENT_PID=$( ps -U "${SUDO_USER:-$USER}" | awk '{print $1}' | tail -n1 )
    elif [ -z "${SSH_AGENT_PID}" ] || ! ( ps "${SSH_AGENT_PID}" >/dev/null ) ; then
        echo "no ssh-agent detected - starting new one" >&2
        SSH_AGENT_PID=$( eval "$( ssh-agent )" | grep -o "[0-9]*" )
    fi
    export SSH_AGENT_PID

    if [ -e /usr/lib/openssh/gnome-ssh-askpass ] ; then
        export SUDO_ASKPASS=/usr/lib/openssh/gnome-ssh-askpass
    fi
}

function setup_x11() {
    # If $DISPLAY is not set, try to find running xserver and export it
    if [ -z "${DISPLAY}" ] ; then
        if ( pidof Xorg >/dev/null || pidof X >/dev/null ) ; then
            DISPLAY=$( pgrep -nfa Xorg 2>&1 | sed 's|.* \(:[0-9]\+\).*|\1|g' )
            DISPLAY=${DISPLAY:-:0}
            export DISPLAY
        fi
    fi
}

function setup_applications() {
    if ( which vim.nox >/dev/null ) ; then
        EDITOR="vim.nox"
    elif ( which vim >/dev/null ) ; then
        EDITOR="vim"
    else
        EDITOR="vi"
    fi

    VISUAL="gvim"
    OPEN='gnome-open'

    SUDO_EDITOR="$EDITOR"
    GIT_EDITOR="$EDITOR"
    SVN_EDITOR="$EDITOR"
    PSQL_EDITOR="$EDITOR"
    PSQL_EDITOR_LINENUMBER_ARG='+'

    if ( which less >/dev/null ) ; then
        PAGER="less -i"
        MANPAGER="less -X"   # no clear afterwards
    else
        PAGER="more"
        MANPAGER="more"
    fi

    export OPEN EDITOR VISUAL SUDO_EDITOR GIT_EDITOR SVN_EDITOR PAGER \
           MANPAGER PSQL_EDITOR PSQL_EDITOR_LINENUMBER_ARG

    alias vi='$EDITOR'
    alias mv='mv -i'
    alias rm='rm -i'
    alias cp='cp -i -r'
    alias mkdir='mkdir -p'
    alias screen='screen -U'
    alias tmux='TERM=screen-256color-bce tmux'
    alias wget='wget -c'
}

function setup_shell() {
    shopt -s autocd                     # if a command is a dir name, cd to it
    shopt -s cdspell                    # correct dir spelling errors on cd
    shopt -s checkjobs                  # print warning if jobs are running on shell exit
    shopt -s checkwinsize               # check winsize and update LINES + COLUMNS
    shopt -s dirspell                   # correct dir spelling errors on completion
    shopt -s extglob                    # extended pattern matching features
    shopt -s globstar                   # ** matches all files, dirs and subdirs
    shopt -s lithist                    # save multi-line commands with newlines
    shopt -s progcomp                   # programmable completion
    shopt -u no_empty_cmd_completion    # don't try to complete empty cmds
    set -o notify                       # report status of terminated bg jobs immediately
    #set -o noclobber                   # do not overwrite files by redirect
}

function setup_config() {
    # contains stuff to handle home as a repo in seperate git-directory
    #
    # in the past I tracked my home directly in ~/.git/ with a gitignore that
    # started with '*'. That worked great except for when it did not. Mostly
    # some thirdparty software acted up when doing dir-walks. So no I'm trying
    # the approach using an alias and my differently named .git/, which now is
    # actually .cfg/. So far it feels ok and thirdparty software will not even
    # notice that it is inside a repo.
    #
    # UPDATE: first downside: thirdparty software will not notice, but my
    #         git-integration in the editor will also not :-(
    #
    alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
}

function setup_exports() {
    export BOOLEAN=(true false)
    export EXTENSIONS_VIDEO='avi,mkv,mp4,mpg,mpeg,wmv,wmvlv,webm,3g,mov,flv'
    export EXTENSIONS_IMAGES='png,jpg,jpeg,gif,bmp,tiff,ico,lzw,raw,ppm,pgm,pbm,psd,img,xcf,psp,svg,ai'
    export EXTENSIONS_AUDIO='flac,mp1,mp2,mp3,ogg,wav,aac,ac3,dts,m4a,mid,midi,mka,mod,oma,wma,opus'
    export EXTENSIONS_DOCUMENTS='asc,rtf,txt,abw,zabw,bzabw,chm,pdf,doc,docx,docm,odm,odt,ods,ots,sdw,stw,wpd,wps,pxl,sxc,xlsx,xlsm,odg,odp,pps,ppsx,ppt,pptm,pptx,sda,sdd,sxd,dot,dotm,dotx,mobi,prc,epub,prc,tpz,azw,azw1,azw3,azw4,kf8,lit,fb2,md,markdown,rst,pandoc'
    export EXTENSIONS_ARCHIVES='7z,s7z,ace,arj,bz,bz2,bzip,bzip2,gz,gzip,lha,lzh,rar,r0,r00,tar,taz,tbz,tbz2,tgz,zip,rpm,deb,xz,iso'
}

function setup_workarounds() {
    # no accesibility gnome thingi
    export NO_AT_BRIDGE=1

    # disable sticky mode
    stty -ixon

    # sudo fix
    alias sudo='sudo '
}

function setup_bash() {
    setup_history
    setup_completion
    setup_colors
    # setup_ssh
    # setup_x11
    setup_applications
    setup_shell
    setup_config
    setup_exports
    setup_workarounds
}

setup_bash "$@"
