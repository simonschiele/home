#!/bin/bash

# shorthands
alias h='history | grep -i'
alias i='apt-get install'
alias calc='bc -l'

# 'pipe-stuff' (filter, sort, math, ...)
alias avg='jq -s "add/length"'
alias min='jq -s min'
alias max='jq -s max'

alias filter.digit='grep -o "[0-9]*"'
alias filter.ip='grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"'
alias filter.temperature='grep -o "[+-][0-9]\{1,\}\.*[0-9]*°[CF]"'
#alias filter.ipv6=
#alias filter.mac=

#alias strip.tags=

# system
alias sudo.lock='sudo -K'
alias user.disable='passwd -dl'
alias ps.by_memory='ps aux --sort -rss'

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
