{ pkgs, ... }:
{
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings =  {
      global = {
        "workgroup" = "WORKGROUP";
         security = "user"; 
         "map to guest" = "bad user"; 
      };
      storage = {
	path = "/mnt/storage";
	browseable = "yes";
	"guest ok" = "no";
        "writeable" = "yes"; 
      };

      zfs = {
	path = "/mnt/tank/data";
	browseable = "yes";
	"guest ok" = "no";
        "writeable" = "yes"; 
      };

      zfs-pictures = {
	path = "/mnt/tank/pictures/share";
	browseable = "yes";
	"guest ok" = "no";
        "writeable" = "yes";
      };

      zfs-videos = {
	path = "/mnt/tank/videos";
	browseable = "no";
	"guest ok" = "no";
        "writeable" = "yes"; 
      };
      macbook-pictures = {
          path = "/mnt/storage/macbook-pictures"; 
          browseable = "yes";
          "guest ok" = "yes";
          "public" = "yes";
          "writable" = "yes";
          "read only" = "no";
          "force user" = "nobody";
     };
    };
  };
}
