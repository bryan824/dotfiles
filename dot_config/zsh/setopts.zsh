# Shell options — http://zsh.sourceforge.net/Doc/Release/Options.html
setopt ALWAYS_TO_END        # full completions move cursor to the end
setopt AUTO_CD              # `dirname` is equivalent to `cd dirname`
setopt AUTO_PARAM_SLASH     # if completed parameter is a directory, add a trailing slash
setopt AUTO_PUSHD           # `cd` pushes directories to the directory stack
setopt C_BASES              # print hex/oct numbers as 0xFF/077 instead of 16#FF/8#77
setopt COMPLETE_IN_WORD     # complete from the cursor rather than from the end of the word
setopt EXTENDED_GLOB        # more powerful globbing
setopt INTERACTIVE_COMMENTS # allow comments in command line
setopt MULTIOS              # allow multiple redirections for the same fd
setopt NO_BG_NICE           # don't nice background jobs
setopt NO_FLOW_CONTROL      # disable start/stop characters in shell editor
setopt PATH_DIRS            # perform path search even on command names with slashes
setopt SHARE_HISTORY        # write and import history on every command

# History options
setopt EXTENDED_HISTORY       # write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST # if history needs to be trimmed, evict dups first
setopt HIST_FIND_NO_DUPS      # don't show dups when searching history
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate commands from history
setopt HIST_IGNORE_SPACE      # don't add commands starting with space to history
setopt HIST_REDUCE_BLANKS     # remove superfluous blanks
setopt HIST_SAVE_NO_DUPS      # don't write duplicate entries to the history file
setopt HIST_VERIFY            # if a command triggers history expansion, show it instead of running

# History variables
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=1000000000
SAVEHIST=1000000000
HISTORY_IGNORE='(cd|ll|lla|lt|d|exit|hist|history|ls|pwd|exit|* --help|h|zsht|.|..|...|....|.....)'

# Completion options
setopt AUTO_MENU       # show completion menu on successive tab press
setopt GLOBDOTS        # dotfiles are matched in completions without specifying the dot
setopt PROMPT_SUBST    # allow expansion in prompts
setopt PUSHDIGNOREDUPS # don't push multiple copies of directories onto the directory stack
setopt PUSHDMINUS      # exchange meanings of + and - with a number in the directory stack
unsetopt LIST_BEEP     # turn off completion list beeps

# zstyle — completion
zstyle ':completion::complete:*' cache-path ${XDG_CACHE_HOME}/zsh/zcompcache

# zstyle — zsh-notify
zstyle ':notify:*' error-title               "zsh: Job failed (#{time_elapsed}s)"
zstyle ':notify:*' success-title             "zsh: Job finished (#{time_elapsed}s)"
zstyle ':notify:*' activate-terminal        yes
zstyle ':notify:*' command-complete-timeout 15
