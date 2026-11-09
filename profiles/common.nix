{ pkgs, ...}:
{
  users.users.nate = {
    isNormalUser = true;
    extraGroups = [ "media" "wheel" "video" "audio" "lp" "scanner" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsgcYRKRS4Z/YOS/arzLFaqJkbXhvdPLbv/dwanrHH4 nate@x1nano" # x1nano key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlI8r09HfhsMmQS3C6PHL5oHHaFc9Ct+TVX5wn12ezB nathaniel@DESKTOP-P5M0S8P" # salieri
    ];
    packages = with pkgs; [
      vimPlugins.Vundle-vim
      yt-dlp
    ];
  };
  environment.systemPackages = with pkgs; [
    curl
    jq
    wget
    git
    busybox
    python3
    vim
    autorestic
    restic
    zfs
    runitor
    smartmontools
    ffmpeg
    iperf
    tailscale
  ];
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
