# Enable decent options. See http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt ALWAYS_TO_END        # full completions move cursor to the end
setopt AUTO_CD              # `dirname` is equivalent to `cd dirname`
setopt AUTO_PARAM_SLASH     # if completed parameter is a directory, add a trailing slash
setopt AUTO_PUSHD           # `cd` pushes directories to the directory stack
setopt COMPLETE_IN_WORD     # complete from the cursor rather than from the end of the word
setopt EXTENDED_GLOB        # more powerful globbing
setopt INTERACTIVE_COMMENTS # allow comments in command line
setopt MULTIOS              # allow multiple redirections for the same fd
setopt NO_BG_NICE           # don't nice background jobs
setopt NO_FLOW_CONTROL      # disable start/stop characters in shell editor
setopt PATH_DIRS            # perform path search even on command names with slashes
setopt SHARE_HISTORY        # write and import history on every command
setopt C_BASES              # print hex/oct numbers as 0xFF/077 instead of 16#FF/8#77

# History
setopt INC_APPEND_HISTORY     # Add commands to HISTFILE in order of execution
setopt EXTENDED_HISTORY       # write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST # if history needs to be trimmed, evict dups first
setopt HIST_FIND_NO_DUPS      # don't show dups when searching history
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS       # don't add consecutive dups to history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE      # don't add commands starting with space to history
setopt HIST_REDUCE_BLANKS     # remove superfluous blanks
setopt HIST_VERIFY            # if a command triggers history expansion, show it instead of running

setopt AUTO_MENU       # Show completion menu on successive tab press
setopt PUSHDIGNOREDUPS # Don’t push multiple copies of directories onto the directory stack
setopt PUSHDMINUS      # Exchange meanings of + and - with a number in the directory stack
setopt GLOBDOTS        # Dotfiles are matched in completions without specifying the dot
setopt PROMPT_SUBST    # Allow expansion in prompts
unsetopt LIST_BEEP     # Turn off completion list beeps

