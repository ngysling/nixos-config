{ pkgs, config, ...}:

{
  users.users = {
    vpn-check = {
      isSystemUser = true;
      group = "vpn-check";
      extraGroups = [ "docker" ]; 
      description = "Service account for VPN health check";
    };
    bw-backup = {
      isSystemUser = true;
      group = "bw-backup";
      description = "Service account for Bitwarden backup";
    };
    autorestic-backup = {
      isSystemUser = true;
      group = "autorestic-backup";
      description = "Service account for Autorestic backups";
    };
    baikal-backup = {
      isSystemUser = true;
      group = "baikal-backup";
      description = "Service account for Baikal contacts/calendar backup";
    };
  };
  users.groups = {
    vpn-check = {};
    bw-backup = {};
    autorestic-backup = {};
    baikal-backup = {};
  };
  sops.secrets = {
    vpn_check_hc_uuid = {
      owner = "vpn-check";
      mode = "0400";
    };
    bw_backup_hc_uuid = {
      owner = "bw-backup";
      mode = "0400";
    };
    autorestic_hc_uuid = {
      owner = "autorestic-backup";
      mode = "0400";
    };
    baikal_backup_hc_uuid = {
      owner = "baikal-backup";
      mode = "0400";
    };
    zfs_scrub_hc_uuid = {
      owner = "root";
      mode = "0400";
    };
  };

  systemd.timers."vpn-check" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "vpn-check.service";
      };
  };
  
  systemd.services."vpn-check" = {
    script = ''
      HC_UUID=$(cat ${config.sops.secrets.vpn_check_hc_uuid.path})
      REAL_IP=$(/run/current-system/sw/bin/curl https://ipinfo.io/ip)
      VPN_IP=$(/run/current-system/sw/bin/docker exec vpn curl https://ipinfo.io/ip)
      if [ "$VPN_IP" != "$REAL_IP" ]; then
         /run/current-system/sw/bin/curl -s --retry 3 https://hc-ping.com/$HC_UUID/0
         exit 0
      else
         /run/current-system/sw/bin/curl -s --retry 3 https://hc-ping.com/$HC_UUID/1
         exit 1
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "vpn-check";
      Group = "vpn-check"; 
    };
  };
  
  systemd.timers."bitwarden-backup" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "bitwarden-backup.service";
      };
  };
  
  systemd.services."bitwarden-backup" = {
    script = ''
      DATADIR=/opt/vaultwarden
      RETENTION_TIME_DAYS=3
      HC_UUID=$(cat ${config.sops.secrets.bw_backup_hc_uuid.path})
  
      function initial() {
        [[ -d $DATADIR/backups ]] || ${pkgs.coreutils}/bin/mkdir $DATADIR/backups
      }
  
      function backup() {
        ${pkgs.sqlite}/bin/sqlite3 $DATADIR/data/db.sqlite3 "VACUUM INTO '$DATADIR/backups/db-$(date '+%Y%m%d-%H%M').sqlite3'"
        ${pkgs.coreutils}/bin/echo "Backed up vaultwarden sqlite3 on $(${pkgs.coreutils}/bin/date '+%Y%m%d-%H%M')"
        ${pkgs.coreutils}/bin/cp -r $DATADIR/data/attachments $DATADIR/backups/attachments-$(${pkgs.coreutils}/bin/date '+%Y%m%d-%H%M')
      }
  
      function cleanup() {
       [[ -f $DATADIR/backups/* ]] && ${pkgs.findutils}/bin/find $DATADIR/backups/ -mindepth 1 -type f -mtime +$RETENTION_TIME_DAYS -delete
       ${pkgs.coreutils}/bin/echo "Cleaned up all backups older than" $RETENTION_TIME_DAYS "days"
     }
  
     initial
     backup
     cleanup
     ${pkgs.curl}/bin/curl --retry 3 https://hc-ping.com/$HC_UUID/$?
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "bw-backup";
      Group = "bw-backup"; 
    };
  };
  
  systemd.timers."zpool-scrub" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "monthly"; 
        Persistent = true; 
        Unit = "zpool-scrub.service";
      };
  };
  
  systemd.services."zpool-scrub" = {
    script = ''
      HC_UUID=$(cat ${config.sops.secrets.zfs_scrub_hc_uuid.path})
      set -eu
      ${pkgs.runitor}/bin/runitor -uuid $HC_UUID -- /run/current-system/sw/bin/zpool scrub tank 
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      ProtectSystem = "strict"; 
      ProtectHome = "true"; 
      PrivateTmp = "true"; 
    };
  };
  systemd.timers."autorestic" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily"; 
        Persistent = true;
        Unit = "autorestic.service";
      };
  };
  
  systemd.services."autorestic" = {
    script = ''
      HC_UUID=$(cat ${config.sops.secrets.autorestic_hc_uuid.path})
      ${pkgs.runitor}/bin/runitor -uuid $HC_UUID -- /run/current-system/sw/bin/autorestic backup --restic-bin /run/current-system/sw/bin/restic -av -c /home/nate/.autorestic.yml --ci cron
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "autorestic-backup";
      Group = "autorestic-backup"; 
    };
  };
  
  systemd.services."baikal-backup" = {
    script = ''
      HC_UUID=$(cat ${config.sops.secrets.baikal_backup_hc_uuid.path})
      ${pkgs.runitor}/bin/runitor -uuid $HC_UUID -- /run/current-system/sw/bin/cp -r /opt/baikal/data /mnt/tank/data/backups/baikal
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "baikal-backup";
      Group = "baikal-backup"; 
    };
  };
  systemd.timers."baikal-backup" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = "true"; 
        Unit = "baikal-backup.service";
      };
  };
}
