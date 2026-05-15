alias cls='clear'
alias path='print -l -- $path'
alias fpath='print -l -- $fpath'

alias df='df -H'
alias du='du -d 1 -h | sort -h'
alias rm='rm -vI'

if [[ $OSTYPE == darwin* ]]; then
  alias topc='top -o cpu'
  alias topm='top -o vsize'
  alias localip='ipconfig getifaddr en0'   # macOS-only: uses BSD ipconfig
else
  alias topc='top -o %CPU'
  alias topm='top -o %MEM'
fi

# Networking — guarded by tool availability
(( $+commands[curl] )) && alias proxyip='curl ifconfig.co/json && echo'
(( $+commands[curl] )) && alias ipinfo='curl "https://ipinfo.io/?token=011b38e90148d1" && echo'
(( $+commands[dig]  )) && alias ip='dig +short myip.opendns.com @resolver1.opendns.com'

# Editor
if (( $+commands[nvim] )); then
  alias v='nvim'
  alias vi='nvim'
  alias vim='nvim'
fi

# Tools
(( $+commands[nix]     )) && alias flakeup='nix flake update'
(( $+commands[kubectl] )) && alias k='kubectl'
(( $+commands[bat]     )) && alias cat='bat --theme="Coldark-Dark" --italic-text=always --style="numbers,changes,header"'
if (( $+commands[kitty] )); then
  alias icat='kitten icat'
  alias s='kitten ssh'
fi

# cp/mv: only set safety fallbacks when rsync is absent
# (rsync-based replacements are commented out; enable if desired)
if (( ! $+commands[rsync] )); then
  alias cp='cp -aivR'
  alias update='cp -uaiv'
  alias mv='mv -iv'
fi

# ls — prefer eza when available
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first --icons --git -bh'
  alias ll='ls -l --git'        # long format, git status
  alias l='ll -a'               # long format, all files
  alias lr='ll -T'              # long format, recursive as a tree
  alias lx='ll -sextension'     # long format, sort by extension
  alias lk='ll -ssize'          # long format, largest file size last
  alias lt='ll -smodified'      # long format, newest modification time last
  alias lc='ll -schanged'       # long format, newest status change (ctime) last
fi
