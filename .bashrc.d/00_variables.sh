#!/bin/bash
#
# Some environment variables and stuff that I use over my other configs.
#

# {{{ Colors

declare -g -A COLORS

COLORS[none]="\e[0m"
COLORS[off]="\e[0m"
COLORS[false]="\e[0m"
COLORS[normal]="\e[0m"

# Basic Colors
COLORS[black]="\e[0;30m"
COLORS[red]="\e[0;31m"
COLORS[green]="\e[0;32m"
COLORS[yellow]="\e[0;33m"
COLORS[blue]="\e[0;34m"
COLORS[purple]="\e[0;35m"
COLORS[cyan]="\e[0;36m"
COLORS[white]="\e[0;37m"

# Bold Colors
COLORS[black_bold]="\e[1;30m"
COLORS[red_bold]="\e[1;31m"
COLORS[green_bold]="\e[1;32m"
COLORS[yellow_bold]="\e[1;33m"
COLORS[blue_bold]="\e[1;34m"
COLORS[purple_bold]="\e[1;35m"
COLORS[cyan_bold]="\e[1;36m"
COLORS[white_bold]="\e[1;37m"

# Underline
COLORS[black_under]="\e[4;30m"
COLORS[red_under]="\e[4;31m"
COLORS[green_under]="\e[4;32m"
COLORS[yellow_under]="\e[4;33m"
COLORS[blue_under]="\e[4;34m"
COLORS[purple_under]="\e[4;35m"
COLORS[cyan_under]="\e[4;36m"
COLORS[white_under]="\e[4;37m"

# Background Colors
COLORS[black_background]="\e[40m"
COLORS[red_background]="\e[41m"
COLORS[green_background]="\e[42m"
COLORS[yellow_background]="\e[43m"
COLORS[blue_background]="\e[44m"
COLORS[purple_background]="\e[45m"
COLORS[cyan_background]="\e[46m"
COLORS[white_background]="\e[47m"
COLORS[gray_background]="\e[100m"

function show.colors() {
    (
        for key in "${!COLORS[@]}" ; do
            echo -e " ${COLORS[$key]} == COLORTEST ${key} == ${COLORS[none]}"
        done
    ) | column -c ${COLUMNS:-120}
}

function color.exists() {
    [ ${COLORS[${1:-none}]+isset} ] && return 0 || return 1
}

function color() {
    ( color.exists ${1:-none} ) && echo -ne "${COLORS[${1:-none}]}"
}

function color.ps1() {
    ( color.exists ${1:-none} ) && echo -ne "\[${COLORS[${1:-none}]}\]"
}

function color.echo() {
    ( color.exists ${1:-black} ) && echo -e "${COLORS[${1:-black}]}${2}${COLORS[none]}"
}

function color.echon() {
    ( color.exists ${1:-black} ) && echo -ne "${COLORS[${1:-black}]}${2}${COLORS[none]}"
}

alias list.colors=show.colors
alias colors.show=show.colors
alias colors.list=show.colors

# }}}

# {{{ Icons

declare -g -A ICONS

ICONS[trademark]='\u2122'
ICONS[copyright]='\u00A9'
ICONS[registered]='\u00AE'
ICONS[asterism]='\u2042'
ICONS[voltage]='\u26A1'
ICONS[whitecircle]='\u25CB'
ICONS[blackcircle]='\u25CF'
ICONS[largecircle]='\u25EF'
ICONS[percent]='\u0025'
ICONS[permille]='\u2030'
ICONS[pilcrow]='\u00B6'
ICONS[peace]='\u262E'
ICONS[yinyang]='\u262F'
ICONS[russia]='\u262D'
ICONS[turkey]='\u262A'
ICONS[skull]='\u2620'
ICONS[heavyheart]='\u2764'
ICONS[whiteheart]='\u2661'
ICONS[blackheart]='\u2665'
ICONS[whitesmiley]='\u263A'
ICONS[blacksmiley]='\u263B'
ICONS[female]='\u2640'
ICONS[male]='\u2642'
ICONS[airplane]='\u2708'
ICONS[radioactive]='\u2622'
ICONS[ohm]='\u2126'
ICONS[pi]='\u220F'
ICONS[cross]='\u2717'
ICONS[fail]='\u2717'
ICONS[error]='\u2717'
ICONS[check]='\u2714'
ICONS[ok]='\u2714'
ICONS[success]='\u2714'
ICONS[warning]='⚠'

function show.icons() {
    (
        for key in "${!ICONS[@]}" ; do
            echo -e " ${ICONS[$key]} : ${key}"
        done
    ) | column -c ${COLUMNS:-80}
}

function icon.exists() {
    [ ${ICONS[${1:-none}]+isset} ] && return 0 || return 1
}

function icon() {
    ( icon.exists ${1:-none} ) && echo -ne "${ICONS[${1:-none}]}"
}

function icon.color() {
    local icon=${1:-fail}
    local color=${2:-red}
    local status=0

    if ( ! icon.exists $icon ) || ( ! color.exists $color ) ; then
        status=1
        icon='fail'
        color='red'
    fi

    color.echon $color $( icon $icon )
    return ${status}
}

alias list.icons=show.icons
alias icons.show=show.icons
alias icons.list=show.icons

# }}}

function depends() {
    local depends_name="$1"
    local depends_type="${2:-bin}"
    local available=false

    case "$depends_type" in
        bin|which|executable)
            which "$depends_name" >/dev/null && available=true
            ;;

        dpkg|deb|debian)
            depends dpkg || exit_error 'please install dpkg if you want to check depends via dpkg'
            dpkg -l | grep -iq "^ii\ \ ${depends_name}\ " && available=true
            ;;

        pip)
            local pip_version pip_output
            depends pip || exit_error 'please install (python-)pip, to check depends via pip'

            pip_version=$( pip --version | awk '{print $2}' )
            if ( es_check_version 1.3 "$pip_version" ) ; then
                pip_output=$( pip show "$depends_name" 2>/dev/null | xargs | awk '{print $3"=="$5}' | sed '/^==$/d' )
            else
                pip_output=$( pip freeze 2>/dev/null | grep "^${depends_name}=" )
            fi

            [[ -n "$pip_output" ]] && available=true
            ;;

        *)
            depends "$depends_name" bin && available=true
            ;;
    esac

    $available
    return
}

function depends_first() {
    local candidate candidate_cmd
    local candidates="$*"
    IFS=","

    for candidate in $candidates ; do
        candidate="${candidate##*( )}"
        candidate="${candidate%%*( )}"
        candidate_cmd=$( echo "$candidate" | cut -f'1' -d' ' )
        if depends "$candidate_cmd" ; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

export BOOLEAN=(true false)
export EXTENSIONS_VIDEO='avi,mkv,mp4,mpg,mpeg,wmv,wmvlv,webm,3g,mov,flv'
export EXTENSIONS_IMAGES='png,jpg,jpeg,gif,bmp,tiff,ico,lzw,raw,ppm,pgm,pbm,psd,img,xcf,psp,svg,ai'
export EXTENSIONS_AUDIO='flac,mp1,mp2,mp3,ogg,wav,aac,ac3,dts,m4a,mid,midi,mka,mod,oma,wma,opus'
export EXTENSIONS_DOCUMENTS='asc,rtf,txt,abw,zabw,bzabw,chm,pdf,doc,docx,docm,odm,odt,ods,ots,sdw,stw,wpd,wps,pxl,sxc,xlsx,xlsm,odg,odp,pps,ppsx,ppt,pptm,pptx,sda,sdd,sxd,dot,dotm,dotx,mobi,prc,epub,pdb,prc,tpz,azw,azw1,azw3,azw4,kf8,lit,fb2,md'
export EXTENSIONS_ARCHIVES='7z,s7z,ace,arj,bz,bz2,bzip,bzip2,gz,gzip,lha,lzh,rar,r0,r00,tar,taz,tbz,tbz2,tgz,zip,rpm,deb,xz'
