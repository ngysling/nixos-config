{ pkgs, ... }: 
{
  imports = [ 
    ./samba.nix
    ./wireguard.nix
    ./maintenance.nix
  ]; 
}
