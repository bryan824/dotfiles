alias cls='clear' # Good 'ol Clear Screen command
alias path="printf '%s\n' $path"
alias fpath="printf '%s\n' $fpath"
(($+commands[kubectl])) && alias k="kubectl"


if (( $+commands[eza] )); then
    alias ls='eza --group-directories-first --icons --git -bh'
    alias ll='ls -l --git'        # Long format, git status
    alias l='ll -a'               # Long format, all files
    alias lr='ll -T'              # Long format, recursive as a tree
    alias lx='ll -sextension'     # Long format, sort by extension
    alias lk='ll -ssize'          # Long format, largest file size last
    alias lt='ll -smodified'      # Long format, newest modification time last
    alias lc='ll -schanged'       # Long format, newest status change (ctime) last
else
fi


alias df='df -H'
alias du='du -d 1 -h | sort -h'

if (( $+commands[rsync] )); then
    # alias cp="rsync -ahvP --backup-dir=/tmp/bkp"
    # alias update="rsync -uahvP --backup-dir=/tmp/bkp"
    # alias mv="rsync -uahvP --backup-dir=/tmp/bkp --remove-source-files"
else
    alias cp="cp -aivR"
    alias update="cp -uaiv"
    alias mv="mv -iv"
fi

if [[ $OSTYPE == "darwin"* ]]; then
    alias topc='top -o cpu'
    alias topm='top -o vsize'
else
    alias topc='top -o %CPU'
    alias topm='top -o %MEM'
fi

alias rm='rm -vI --preserve-root'
alias localip='ipconfig getifaddr en0'
alias proxyip="curl ifconfig.co/json && echo"
alias ipinfo="curl \"https://ipinfo.io/?token=011b38e90148d1\" && echo"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
