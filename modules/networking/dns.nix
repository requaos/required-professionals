{
  lib,
  pkgs,
  config,
  ...
}: {
  networking = {
    nameservers = ["127.0.0.1"];
    firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };
  services = {
    # Locale service discovery and mDNS
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    nscd.enableNsncd = true;
    # DNS
    adguardhome = {
      enable = true;
      # extraArgs = [];
      mutableSettings = false;
      settings = {
        # disable default rate limit of 20
        ratelimit = 0;

        http = {
          address = "0.0.0.0:8053";
        };

        dns = {
          bind_hosts = ["0.0.0.0"];
          port = 53;

          bootstrap_dns = [
            # use unsecured quad9 for bootstrap
            "9.9.9.10"
          ];

          upstream_dns = [
            # send unqualified names to router (ex: router, desktop, etc)
            # "[//]192.168.1.1"
            # send .lan to router
            # "[/lan/]192.168.1.1"
            # internal dns server
            # "[/*.${domain}/]127.0.0.1"
            # send www and root domain to upstream dns
            # "[/${domain}/www.${domain}/]#"
            # forward everything else to quad9
            "tls://dns.quad9.net"
          ];

          # rewrites = [
          #   # rewrite domain traffic to local ip
          #   {
          #     domain = "*.${domain}";
          #     answer = "192.168.1.2";
          #   }
          #   # revert root domain and www traffic back to upstream
          #   {
          #     domain = domain;
          #     answer = "A";
          #   }
          #   {
          #     domain = "www.${domain}";
          #     answer = "A";
          #   }
          # ];
        };

        querylog = {
          enabled = true;
          interval = "168h";
        };

        statistics = {
          enabled = true;
          interval = "168h";
        };
      };
    };
  };
}
