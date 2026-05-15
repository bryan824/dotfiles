# Trim trailing newline from pasted text so a copied line doesn't auto-execute.
# Ref: https://unix.stackexchange.com/questions/693118
bracketed-paste() { zle .$WIDGET && LBUFFER=${LBUFFER%$'\n'}; }
zle -N bracketed-paste
