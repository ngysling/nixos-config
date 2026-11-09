{ config, ... }: 
{
  networking.firewall = {
    allowedUDPPorts = [ 8443 ]; # Clients and peers can use the same port, see listenport
  };
  networking.wireguard.interfaces = {
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.1.10.3/24" ];
      listenPort = 8443;
      privateKeyFile = config.sops.secrets.wireguard_private_key.path; 
      mtu = 1320; 
      peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          publicKey = "1wN+L9lKtqMvYHhyykHGdVnwshveAxhJPuuGx2ysPGU=";
          allowedIPs = [ "10.1.10.1/32" ];
          endpoint = "104.168.64.164:8443"; 
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
