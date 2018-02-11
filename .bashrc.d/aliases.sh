#!/bin/bash

alias calc='bc -l'

alias date.format='date --help | sed -n "/^FORMAT/,/%Z/p"'
alias date.timestamp='date +%s'
alias date.week='date +%V'
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
