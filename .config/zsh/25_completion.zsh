# compinit and completion styles. Replaces zim's `completion` module (disabled
# in .zimrc), which zstat'd every one of ~1960 fpath functions each startup to
# spot a stale dumpfile — 6ms, a third of startup. Seven directory stats find
# the same thing: adding or removing a file bumps its directory's mtime, and an
# edit to an existing one needs no rebuild (the dump maps command -> function).
#
# Must run after 20, which puts zsh-completions and $ZDOTDIR/completions on
# fpath.

fpath=(${ZIM_HOME}/modules/completion/functions ${fpath})  # _zimfw

() {
  local zdumpfile=$ZDOTDIR/.zcompdump zdir
  autoload -Uz compinit

  for zdir in ${fpath}; do
    # touch: a full compinit rewrites the dumpfile only when its contents
    # change, so without it the trigger stays armed on every later startup.
    [[ ${zdir} -nt ${zdumpfile} ]] && { compinit -d ${zdumpfile}; touch ${zdumpfile}; break }
  done
  (( ${+functions[compdef]} )) || compinit -C -d ${zdumpfile}
  [[ ${zdumpfile}.zwc -nt ${zdumpfile} ]] || zcompile ${zdumpfile}
}

# Shell options live in 10_options.zsh, including the completion ones.

zstyle ':completion::complete:*' use-cache on
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' single-ignored show
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'
zstyle ':completion:*:*:-subscript-:*' tag-order 'indexes' 'parameters'
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*:*:*:users' ignored-patterns '_*'

# Smart case: plain case-insensitive matching is broken in zsh 5.9.
# https://www.zsh.org/mla/workers/2022/msg01229.html
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+r:|[._-]=* r:|=*' '+l:|=*'

zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts{,2} 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts 2>/dev/null)"}%%(\#)*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config{,.d/*(N)} 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'
