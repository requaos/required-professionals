{
  lib,
  pkgs,
  config,
  inputs,
  clan-core,
  ...
}: let
  system = "x86_64-linux";
  rust-dev = with builtins.removeAttrs
  (
    inputs.fenix.packages.${system}.latest
    // {inherit (inputs.fenix.packages.${system}) rust-analyzer targets;}
  )
  ["withComponents"]; [
    cargo
    (lib.lowPrio clippy)
    rust-src
    rustc
    rustfmt
    rust-analyzer
    targets.wasm32-unknown-unknown.latest.rust-std

    # Necessary for the openssl-sys crate:
    pkgs.openssl_1_1
    pkgs.pkg-config

    pkgs.jetbrains.rust-rover
  ];
in {
  imports = [
    # Enables the OpenSSH server for remote access
    # clan-core.clanModules.sshd
    # Set a root password
    # clan-core.clanModules.root-password
    # clan-core.clanModules.user-password
    # clan-core.clanModules.state-version
  ];

  # generate a random password for our user below
  # can be read using `clan secrets get <machine-name>-user-password` command
  # clan.user-password.user = "user";
  users.users = {
    req = {
      initialHashedPassword = "$y$j9T$WKj3UyDIuS1i5jl8u62Gm0$trGjHf0T4ob87gdP.qQvwKIjCND.r8ckCdupE1yLgy8";
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "input"
        "dialout"
        "cdrom"
      ];
      uid = 1000;
      openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
      # default shell
      useDefaultShell = false;
      shell = pkgs.nushell;
    };
    root = {
      initialHashedPassword = "$y$j9T$97uoYd9ttSGxW/AVloAC5.$pVZJdhmTAF.1iytnzLvpqSAhM/NqwQI.sem6XvYfd39";
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
    systemPackages = with pkgs;
      [
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

        # t1000-e tracker card programming
        adafruit-nrfutil

        # cd-burning
        cdrkit
        cdrdao
        kdePackages.k3b
      ]
      ++ rust-dev;

    shellAliases = {
      # fix nixos-option for flake compat
      #nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";
      userctl = "systemctl --user";
    };
    variables = {
      EDITOR = "${pkgs.vim}/bin/vim";
      VISUAL = "${pkgs.vim}/bin/vim";
    };

    sessionVariables = {
      RUST_SRC_PATH = "${inputs.fenix.packages.${system}.latest.rust-src}";
      PKG_CONFIG_PATH = "${pkgs.openssl_1_1.dev}/lib/pkgconfig";
      OPENSSL_DIR = "${pkgs.openssl_1_1}";
      LD_LIBRARY_PATH = lib.makeLibraryPath [pkgs.openssl_1_1];
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
    # For rage encryption, all hosts need a ssh key pair
    openssh = {
      enable = true;
      openFirewall = lib.mkDefault true;
      startWhenNeeded = true;
      settings = {
        X11Forwarding = true;
      };
    };
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
    # Service that makes Out of Memory Killer more effective
    earlyoom.enable = true;
  };
  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=5s
    '';
  };
  security = {
    wrappers = with pkgs; {
      cdrdao = {
        setuid = true;
        owner = "root";
        group = "root";
        source = "${cdrdao}/bin/cdrdao";
      };
      cdrecord = {
        setuid = true;
        owner = "root";
        group = "root";
        source = "${cdrtools}/bin/cdrecord";
      };
    };
  };
}
