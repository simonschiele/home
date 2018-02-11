#!/bin/bash

alias calc='bc -l'

alias date.format='date --help | sed -n "/^FORMAT/,/%Z/p"'
alias date.timestamp='date +%s'
alias date.timestamp_long='date +%s%N'
alias date.calendarweek='date +%V'
alias date.YY-mm-dd='date "+%Y-%m-%d"'
alias date.YY-mm-dd_HH_MM='date "+%Y-%m-%d_%H-%M"'
alias stopwatch='time read -n 1'

alias avg='jq -s "add/length"'
alias min='jq -s min'
alias max='jq -s max'

alias filter.digit='grep -o "[0-9]*"'
alias filter.ip='grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"'
alias filter.temperature='grep -o "[+-][0-9]\{1,\}\.*[0-9]*°[CF]"'

alias strip.tags='sed -e "s|<[^>]*>||g"'

alias random.ip='nmap -iR 1 -sL -n | grep.ip -o'
alias random.mac='openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//"'
alias random.lotto='shuf -i 1-49 -n 6 | sort -n | xargs'

# system
alias sudo.lock='sudo -K'
alias user.disable='passwd -dl'
alias ps.by_memory='ps aux --sort -rss'

# debian
alias debian.version='lsb_release -a'
alias debian.bugs='bts'
alias debian.packages_by_size='dpkg-query -W --showformat="\${Installed-Size;10}\t\${Package}\n" | sort -k1,1n'
alias debian.configfiles='dpkg-query -f "\n\${Package} \n\${Conffiles}\n" -W'

# dev
alias patch.from_diff='patch -Np0 -i'

# scanning
alias nmap.fast_udp="sudo nmap -sU --max-retries 1 --min-rate 5000 -p 1-65535"

# downloads
alias youtube-dl='youtube-dl --no-call-home --no-check-certificate --ignore-errors --xattrs --no-playlist'
alias youtube-dl.mp3='youtube-dl -x --audio-format mp3 --audio-quality 0'
alias youtube-dl.playlist='youtube-dl --yes-playlist --playlist-start 1'
alias youtube-dl.mp3_playlist='youtube-dl.mp3 --yes-playlist --playlist-start 1'
alias wget.mirror_complete='wget --random-wait -r -p -e robots=off -U mozilla'
alias wget.mirror_images='wget -r -l1 --no-parent -nH -nd -P/tmp -A".gif,.jpg,.jpeg,.png"'

# toys
alias ascii.starwars='telnet towel.blinkenlights.nl'

#### incoming
alias find.dir='find -type d'
alias find.files='find -type f'
alias find.exec='find ! -type d -executable'
alias find.repos='find -name .git -or -name .svn -or -name .bzr -or -name .hg -or -name CSV | while read dir ; do echo "$dir" | sed "s|\(.\+\)/\.\([a-z]\+\)$|\2: \1|g" ; done'
alias find.comma='ls -r --format=commas'
alias find.dead.links='find.dead_links'
alias find.links='find -type l'
alias find.links.dead='find -L -type l'
alias find.bigger.10m='find -size +10M'
alias find.bigger.100m='find -size +100M'
alias find.bigger.1000m='find -size +1000M'
alias find.last_edited='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 1000'
alias find.last_edited.1000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 1000'
alias find.last_edited.3000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 3000'
alias find.last_edited.5000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 5000'
alias find.last_edited.10000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 10000'
alias find.last_edited.30000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 30000'
alias find.last_edited.50000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 50000'
alias find.last_edited.100000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 100000'
alias find.last_edited.less='find . -type f -printf "%T@ %T+ %p\n" | sort -n | less'
alias find.videos="find . ! -type d $( echo ${EXTENSIONS_VIDEO}\" | sed -e "s|,|\"\ \-o\ \-iname \"*|g" -e "s|^|\ \-iname \"*|g" )"
alias find.images="find . ! -type d $( echo ${EXTENSIONS_IMAGES}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
alias find.audio="find . ! -type d $( echo ${EXTENSIONS_AUDIO}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
alias find.documents="find . ! -type d $( echo ${EXTENSIONS_DOCUMENTS}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
alias find.archives="find . ! -type d $( echo ${EXTENSIONS_ARCHIVES}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
alias show.ip_remote='addr=$( dig +short myip.opendns.com @resolver1.opendns.com | grep.ip ) ; echo remote:${addr:-$( wget -q -O- icanhazip.com | grep.ip )}'
alias show.ip_local='LANG=C /sbin/ifconfig | grep -o -e "^[^\ ]*" -e "^\ *inet addr:\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}" | tr "\n" " " | sed -e "s|\ *inet addr||g" -e "s|\ |\n|g"' #-e "s|:\(.*\)$|: $( color yellow )\1$( color none )|g"'
alias show.ip='show.ip_local | sed "s|:\(.*\)$|: $( color yellow )\1$( color none )|g" ; show.ip_remote | sed "s|:\(.*\)$|: $( color green )\1$( color none )|g"'
alias show.io='echo -n d | nmon -s 1'
alias show.tcp='sudo netstat -atp'
alias show.tcp_stats='sudo netstat -st'
alias show.udp='sudo netstat -aup'
alias show.udp_stats='sudo netstat -su'
alias show.window_class='xprop | grep CLASS'
alias show.resolution='LANG=C xrandr -q | grep -o "current [0-9]\{3,4\} x [0-9]\{3,4\}" | sed -e "s|current ||g" -e "s|\ ||g"'
alias show.certs='openssl s_client -connect '
alias show.keycodes='xev | grep -e keycode -e button'
alias show.usb_sticks='for dev in $( udisks --dump | grep device-file | sed "s|^.*\:\ *\(.*\)|\1|g" ) ; do udisks --show-info ${dev} | grep -qi "removable.*1" && echo ${dev} ; done ; true ; unset dev'
