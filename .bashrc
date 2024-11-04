# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

for file in ~/.{aliases,exports,path}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Use starship prompt
eval "$(starship init bash)"
