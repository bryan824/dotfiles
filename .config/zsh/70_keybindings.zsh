# Option-arrow word jumps, the macOS gesture. kitty sends these with
# macos_option_as_alt; zim's input module binds only the Ctrl-arrow forms.
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word

# Trim trailing newline from pasted text so a copied line doesn't auto-execute.
# Ref: https://unix.stackexchange.com/questions/693118
bracketed-paste() { zle .$WIDGET && LBUFFER=${LBUFFER%$'\n'}; }
zle -N bracketed-paste
