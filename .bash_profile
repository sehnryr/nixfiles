# .bash_profile

[[ -f ~/.bashrc ]] && . ~/.bashrc

# start ssh-agent
eval $(ssh-agent -s) > /dev/null
ssh-add -q ~/.ssh/id_ed25519
