# Agenix over OpNix

OpNix requires network to pull the secrets from 1Password which adds a layer of
complexity and also a SPOF (Single Point Of Failure) in the case 1Password is
inaccessible.

Agenix instead using age allows for the secrets to be encrypted and versionned
through the repo, only needed a key to be available for decryption.

At first I didn't want to use Agenix or age since I had to put my ssh key on my
filesystem where I started to use password managers like 1Password which handled
ssh keys.

Age have a plugin ecosystem which will allow me to use a yubikey once I get my
hands on one.
