# Completion — compinit and the completion zstyles.
#
# This replaces zim's `completion` module, which is left installed but disabled
# (`-d` in .zimrc) so its functions/ directory still ships _zimfw.
#
# Why: that module decides whether the dumpfile is stale by zstat'ing every
# completion function in fpath — ~1960 files here — on every single startup.
# Measured at ~6ms, which was 35% of the whole shell startup, to detect a change
# that happens a few times a month. The check below costs one stat per fpath
# entry (7 here) and detects the same thing; see the comment on it.
#
# Everything else in this file is that module's behaviour, kept deliberately
# identical: same dumpfile, same zcompile, same setopts, same zstyles. Case
# sensitivity is fixed at zim's default (insensitive) rather than left behind a
# zstyle nothing here ever set.
#
# Must run before 30_mise.zsh: mise runs its own `compinit -i` when compdef is
# still undefined.

# _zimfw lives here; zim would have added it when initializing the module.
fpath=(${ZIM_HOME}/modules/completion/functions ${fpath})

() {
  # EXTENDED_GLOB for the (#q…) qualifier below; -L restores options on return.
  # 10_options.zsh may or may not have set it, so do not depend on that.
  builtin emulate -L zsh -o EXTENDED_GLOB

  local zdumpfile=$ZDOTDIR/.zcompdump

  # Rebuild when the *set* of completion functions could have changed.
  #
  # Adding, removing or renaming a file updates its directory's mtime, so one
  # stat per fpath entry (~20) covers every directory zsh will look in —
  # zim's module stat'd every function file in all of them (~1960) to learn the
  # same thing. Editing an existing completion's contents needs no rebuild at
  # all: the dumpfile only maps command -> function name, and the function
  # itself is autoloaded from fpath when it is first used.
  #
  # Glob qualifiers do not expand inside [[ ]], so the age test runs out here:
  # this array is empty unless the dumpfile is older than 24h. That ceiling is
  # belt-and-braces for anything the directory mtimes somehow miss.
  local -a zstale=( ${zdumpfile}(#qN.mh+24) )
  local zdir
  [[ -e ${zdumpfile} ]] || zstale=(missing)
  if (( ! ${#zstale} )); then
    for zdir in ${fpath}; do
      [[ ${zdir} -nt ${zdumpfile} ]] && { zstale=(${zdir}); break }
    done
  fi

  autoload -Uz compinit
  if (( ${#zstale} )); then
    compinit -d ${zdumpfile}
    # A full compinit rewrites the dumpfile only when its *contents* change, so
    # after a no-op rebuild the mtime would stay behind whatever triggered this
    # branch — and the expensive path would then run on every single startup.
    # Stamping it is what makes the trigger clear itself.
    touch ${zdumpfile}
  else
    compinit -C -d ${zdumpfile}
  fi

  # Compiling the dumpfile is a significant speedup, and zim did it too.
  if [[ ! ${zdumpfile}.zwc -nt ${zdumpfile} ]] zcompile ${zdumpfile}
}

#
# Zsh options
#

# Move cursor to end of word if a full completion is inserted.
setopt ALWAYS_TO_END

# Completion is done from both ends of the cursor.
setopt COMPLETE_IN_WORD

setopt NO_CASE_GLOB

# Don't beep on ambiguous completions.
setopt NO_LIST_BEEP

#
# Completion module options
#

# Enable caching
zstyle ':completion::complete:*' use-cache on

# Group matches and describe.
zstyle ':completion:*' menu select
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# "Smart" case sensitivity. Plain case-insensitive matching
# ('m:{[:lower:][:upper:]}={[:upper:][:lower:]}') is broken in Zsh 5.9.
# See https://www.zsh.org/mla/workers/2022/msg01229.html
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+r:|[._-]=* r:|=*' '+l:|=*'

# Insert a TAB character instead of performing completion when left buffer is empty.
zstyle ':completion:*' insert-tab false

# Ignore useless commands and functions
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'
# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order 'indexes' 'parameters'

# Directories
if (( ${+LS_COLORS} )); then
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
else
  # Use same LS_COLORS definition from utility module, in case it was not set
  zstyle ':completion:*:default' list-colors ${(s.:.):-di=1;34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43}
fi
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts{,2} 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts 2>/dev/null; (( ${+commands[ypcat]} )) && ypcat hosts 2>/dev/null)"}%%(\#)*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config{,.d/*(N)} 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns \
  '_*' adm amanda apache avahi beaglidx bin cacti canna clamav daemon dbus \
  distcache dovecot fax ftp games gdm gkrellmd gopher hacluster haldaemon \
  halt hsqldb ident junkbust ldap lp mail mailman mailnull mldonkey mysql \
  nagios named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
  operator pcap postfix postgres privoxy pulse pvm quagga radvd rpc rpcuser \
  rpm shutdown squid sshd sync uucp vcsa xfs

# ... unless we really want to.
zstyle ':completion:*' single-ignored show

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
