{
  lib,
  pkgs,
  config,
  ...
}: {
  programs = {
    openvpn3 = {
      enable = true;
      package = pkgs.openvpn3.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ./vpn.patch # point to wherever you have this file, or use something like `fetchpatch`
          ];
        enableSystemdResolved = config.services.resolved.enable;
      });
    };
  };
  services = {
    openvpn.servers = {
      officeVPN = {
        autoStart = false;
        config = ''
          config /home/req/CalamuVPN/calamu-vpn.ovpn
        '';
        updateResolvConf = true;
      };
      calamulabs = {
        autoStart = false;
        config = ''
          config /home/req/CalamuVPN/EricsVpn.ovpn
          auth-user-pass /home/req/CalamuVPN/erics_creds.txt
          route-nopull
          # subnets
          route 192.168.0.0 255.255.255.0
          route 192.168.2.0 255.255.255.0
          route 192.168.3.0 255.255.255.0
          route 192.168.4.0 255.255.255.0
          route 192.168.5.0 255.255.255.0
          route 192.168.6.0 255.255.255.0
          route 192.168.7.0 255.255.255.0
          route 192.168.8.0 255.255.255.0
          route 192.168.9.0 255.255.255.0
          route 192.168.10.0 255.255.255.0
          route 192.168.11.0 255.255.255.0
          route 192.168.12.0 255.255.255.0
          route 192.168.13.0 255.255.255.0
          route 192.168.14.0 255.255.255.0
          route 192.168.15.0 255.255.255.0
          # eric desktop
          route 192.168.1.5 255.255.255.255
          # minio / s3.calamulabs.com
          #route 192.168.0.122 255.255.255.255
          #route 192.168.0.230 255.255.255.255
          # vshphere / esxi / vsphere.devopsvector.comx
          #route 192.168.2.120 255.255.255.255
          #route 192.168.0.120 255.255.255.255
          #route 192.168.4.100 255.255.255.255
          #route 192.168.7.100 255.255.255.255
          # vms
          #route 192.168.13.0 255.255.255.0
          # vms
          #route 192.168.15.0 255.255.255.0
        '';
        updateResolvConf = false;
      };
    };
  };
}
