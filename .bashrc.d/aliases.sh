#!/bin/bash
#
# Rules:
#   Keep aliases in single quotes
#   Follow naming pattern
#

# path/directory
alias cwd='pwd | tr -d "\r\n" | xclip -selection clipboard'

# date + time
alias date.format='date --help | sed -n "/^FORMAT/,/%Z/p"'
alias date.timestamp='date +%s'
alias date.timestamp_long='date +%s%N'
alias date.calendarweek='date +%V'
alias date.YY-mm-dd='date "+%Y-%m-%d"'
alias date.YY-mm-dd_HH_MM='date "+%Y-%m-%d_%H-%M"'
alias stopwatch='time read -n 1'

# calculation
alias calc='bc -l'
alias avg='jq -s "add/length"'
alias min='jq -s min'
alias max='jq -s max'

# filter/replacer/enricher/...
alias filter.digit='grep -o "[0-9]*"'
alias filter.ip='grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"'
alias filter.temperature='grep -o "[+-][0-9]\{1,\}\.*[0-9]*°[CF]"'
alias strip.tags='sed -e "s|<[^>]*>||g"'

# generate data
alias random.ipv4='nmap -iR 1 -sL -n | filter.ip'
alias random.mac='openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//"'
alias random.lotto='shuf -i 1-49 -n 6 | sort -n | xargs'

# find
alias find.exec='find ! -type d -executable'
alias find.repos='find -name .git -or -name .svn -or -name .bzr -or -name .hg -or -name CSV | while read dir ; do echo "$dir" | sed "s|\(.\+\)/\.\([a-z]\+\)$|\2: \1|g" ; done'
alias find.dead_links='find -L -type l'
alias find.bigger.10m='find -size +10M'
alias find.bigger.100m='find -size +100M'
alias find.bigger.1000m='find -size +1000M'
alias find.last_edited_directory='find . -type d -printf "%T@ %T+ %p\n" | sort -n | tail -n 250'
alias find.last_edited='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 1000'
alias find.last_edited.1000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 1000'
alias find.last_edited.3000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 3000'
alias find.last_edited.5000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 5000'
alias find.last_edited.10000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 10000'
alias find.last_edited.30000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 30000'
alias find.last_edited.50000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 50000'
alias find.last_edited.100000='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 100000'
alias find.last_edited.less='find . -type f -printf "%T@ %T+ %p\n" | sort -n | less'
#alias find.videos="find . ! -type d $( echo ${EXTENSIONS_VIDEO}\" | sed -e "s|,|\"\ \-o\ \-iname \"*|g" -e "s|^|\ \-iname \"*|g" )"
#alias find.images="find . ! -type d $( echo ${EXTENSIONS_IMAGES}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
#alias find.audio="find . ! -type d $( echo ${EXTENSIONS_AUDIO}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
#alias find.documents="find . ! -type d $( echo ${EXTENSIONS_DOCUMENTS}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
#alias find.archives="find . ! -type d $( echo ${EXTENSIONS_ARCHIVES}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"

# show.*
alias show.io='echo -n d | nmon -s 1'
alias show.tcp='sudo netstat -atp'
alias show.tcp_stats='sudo netstat -st'
alias show.udp='sudo netstat -aup'
alias show.udp_stats='sudo netstat -su'
alias show.window_class='xprop | grep CLASS'
alias show.keycodes='xev | grep -e keycode -e button'
alias show.ip_external='dig +short myip.opendns.com @resolver1.opendns.com'

# system
alias sudo.lock='sudo -K'
alias udev.reload_rules='sudo udevadm control --reload-rules && sudo udevadm trigger'
alias user.disable='passwd -dl'
alias ps.by_memory='ps aux --sort -rss'

# debian
alias debian.version='lsb_release -a'
alias debian.bugs='bts'
alias debian.packages_by_size='dpkg-query -W --showformat="\${Installed-Size;10}\t\${Package}\n" | sort -k1,1n'
alias debian.build_src_package='dpkg-buildpackage -us -uc'
alias debian.configfiles='dpkg-query -f "\n\${Package} \n\${Conffiles}\n" -W'

# scanning
alias nmap.fast_udp='sudo nmap -sU --max-retries 1 --min-rate 5000 -p 1-65535'
alias nmap.show_hosts='nmap -sP $( ip addr show dev $( ip route | grep "^default" | awk "{print $5}" ) | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\." | head -n 1 )0/24 | grep -v "^Host is" | sed "s/^Nmap scan report for //g"'

# download
alias youtube-dl='youtube-dl --no-call-home --no-check-certificate --ignore-errors --no-playlist'
alias youtube-dl.mp3='youtube-dl -x --audio-format mp3 --audio-quality 0'
alias youtube-dl.playlist='youtube-dl --yes-playlist --playlist-start 1'
alias youtube-dl.mp3_playlist='youtube-dl.mp3 --yes-playlist --playlist-start 1'
alias wget.mirror_complete='wget --random-wait -r -p -e robots=off -U mozilla'
alias wget.mirror_images='wget -r -l1 --no-parent -nH -nd -P/tmp -A".gif,.jpg,.jpeg,.png"'

# toys
alias ascii.starwars='telnet towel.blinkenlights.nl'
