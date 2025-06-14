let
  master = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPO/hKBeNBJVbq8yPL13KRBLCn+gpXyNtAs1UyvyP9Z";
in
{
  "secrets/arch-user-repository-ssh.age".publicKeys = [ master ];
  "secrets/clever-cloud-ssh.age".publicKeys = [ master ];
}
