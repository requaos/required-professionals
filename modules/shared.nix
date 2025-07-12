{
  lib,
  pkgs,
  config,
  inputs,
  clan-core,
  ...
}: {
  imports = [
    # Enables the OpenSSH server for remote access
    clan-core.clanModules.sshd
    # Set a root password
    clan-core.clanModules.root-password
    clan-core.clanModules.user-password
    clan-core.clanModules.state-version
  ];

  # generate a random password for our user below
  # can be read using `clan secrets get <machine-name>-user-password` command
  # clan.user-password.user = "user";
  users.users = {
    user = {
      initialHashedPassword = "$y$j9T$WKj3UyDIuS1i5jl8u62Gm0$trGjHf0T4ob87gdP.qQvwKIjCND.r8ckCdupE1yLgy8";
      isNormalUser = true;
      createHome = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "input"
      ];
      uid = 1000;
      openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
      # default shell
      useDefaultShell = false;
      shell = pkgs.nushell;
    };
    root = {
      initialHashedPassword = "$y$j9T$udmWOUL83BI/zSUuqJOXR.$8xR73OTkV52DQVdp6PspvROhLzG8Mgj3VQjG8AOub34";
    };
  };
  ssh = {
    # For rage encryption, all hosts need a ssh key pair
    openssh = {
      enable = true;
      openFirewall = lib.mkDefault true;
      startWhenNeeded = true;
      settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = true;
        X11Forwarding = true;
      };
    };
  };
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };
  environment = {
    # Selection of sysadmin tools that can come in handy
    systemPackages = with pkgs; [
      # Linux, non-darwin, packages
      dosfstools
      gptfdisk
      iputils
      usbutils
      utillinux

      # neofetch
      killall

      # niff tool, rust port of nvd should be used instead, but...
      nvd

      # must come from unstable channel
      # alejandra
      binutils
      coreutils
      curl
      dnsutils
      fd
      git
      bottom
      jq
      libxml2
      manix
      moreutils
      nix-index
      nmap
      pciutils
      ripgrep
      skim
      whois
      graphviz
      unzip
      p7zip

      # magic shell history
      # atuin
      blesh

      # debug info
      dmidecode

      # maybe linux/bash specific. YOLO
      mcfly
      brightnessctl

      # CORE UTILS
      vim
      gnused # sed
      tree

      # MODERN CORE UTILS
      topgrade
      tealdeer # tldr

      ripgrep
      fd

      # NETWORK TOOLS
      drill
      curl
      wget
      # maybe this doesn't go here, or we flag as optional against `home-manager.users.{userName}.programs.networkmanager.enable = true'
      networkmanager

      # PERF TOOLS
      htop
      nethogs
      # radeontop
      # nvtop
    ];

    shellAliases = {
      # fix nixos-option for flake compat
      #nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";
      userctl = "systemctl --user";
    };
    variables = {
      EDITOR = "${pkgs.vim}/bin/vim";
      VISUAL = "${pkgs.vim}/bin/vim";
    };
  };
  fonts = {
    packages = with pkgs; [
      nerd-fonts.hack
      nerd-fonts.iosevka
      nerd-fonts.roboto-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.dejavu-sans-mono
    ];

    fontconfig.defaultFonts = {
      monospace = ["DejaVuSansM Nerd Font Mono"];
      sansSerif = ["Hack Nerd Font"];
    };
  };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    settings = {
      sandbox = true;
      show-trace = true;
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel"];
      allowed-users = ["@wheel"];
      substituters = [
        "https://cache.nixos.org/"
        "https://nrdxp.cachix.org"
        "https://nix-community.cachix.org"
        "https://colmena.cachix.org"
        "https://ezkea.cachix.org"
      ];
      trusted-public-keys = [
        "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes dynamic-derivations fetch-closure
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
  };
  services = {
    dbus.enable = true;

    gnome.gnome-keyring.enable = true;

    # Printers
    printing = {
      enable = true;
      browsing = true;
      drivers = with pkgs; [
        gutenprint
        # hplip
        postscript-lexmark
      ];
      browsedConf = ''
        BrowseDNSSDSubTypes _cups,_print
        BrowseLocalProtocols all
        BrowseRemoteProtocols all
        CreateIPPPrinterQueues All

        BrowseProtocols all
      '';
    };
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

    # Service that makes Out of Memory Killer more effective
    earlyoom.enable = true;
  };
  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=5s
    '';
  };
  networking = {
    nameservers = ["127.0.0.1"];
    firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };
  programs = {
    openvpn3 = {
      enable = true;
      package = pkgs.openvpn3.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ./fix-tests.patch # point to wherever you have this file, or use something like `fetchpatch`
          ];
        enableSystemdResolved = config.services.resolved.enable;
      });
    };
  };
}
