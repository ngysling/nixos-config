{ config, lib, pkgs, pkgs-unstable, ... }:
{
    imports =
     [
       ./hardware-configuration.nix
       ./hosted
       ../../profiles/common.nix
     ];
    sops = { 
      defaultSopsFile = ./secrets.yaml; 
      age.keyFile = "/var/lib/sops-nix/keys.txt"; 
      secrets = {
        wireguard_private_key = {
          mode = "0400";
        };
      #  vpn_check_hc_uuid = {
      #    owner = "nate";  
      #  };
      #  bw_backup_hc_uuid = {};
      #  zfs_scrub_hc_uuid = {};
      #  autorestic_hc_uuid = {};
      #  baikal_backup_hc_uuid = {};
      };
    }; 
   boot = {
     kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
     supportedFilesystems = [ "zfs" ];
     zfs.forceImportRoot = false;
     loader.grub = {
       enable = true;
       device = "nodev";
     };
   };
     services.zfs.autoSnapshot = { 
       enable = true;
    }; 
  environment.systemPackages = [ 
     pkgs.mergerfs
  ]; 
  networking = {
    hostName = "repono";
    hostId = "9b5cbef2";
    firewall.allowedTCPPorts = [ 22 80 443 8008 8080 8989 7878 32400 4921 4999 2283 ]; # ssh, reverse proxy, bittorrent, traefik, sonarr, radarr, plex, vaultwarden, nc, immich
  };
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  virtualisation.docker.enable = true;

  users.groups.media = { gid = 321; };
  users.users.docker = {
    group = "docker";
    extraGroups = [ "media" ];
    uid = 1001;
    isSystemUser= true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };
  programs.ssh.startAgent = true; 

#  services.scrutiny = {
#    enable = true;
#    openFirewall = true;
#  };

#  services.immich = {
#    enable = true;
#    accelerationDevices = [ "/dev/dri/renderD128" ];
#    port = 2283;
#    mediaLocation = "/mnt/tank/immich"; 
#  }; 
#    services.postgresql = {
#      enable = true;
#      package = pkgs.postgresql_18;
#    };
#  hardware.graphics = {
#    enable = true; 
#    extraPackages = with pkgs; [ intel-vaapi-driver ]; 
#  };
#  environment.sessionVariables = { 
#    LIBVA_DRIVER_NAME = "iHD"; 
#  }; 
#  # users.users.immich.extraGroups = [ "video" "render" ]; 
  system.stateVersion = "23.11";
}

