# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Avoid duplicates
HISTCONTROL=ignoredups:erasedups
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

for file in ~/.{path,exports,aliases,prompt,completion}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file
