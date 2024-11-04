# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

for file in ~/.{path,exports,aliases,prompt,completion}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file
