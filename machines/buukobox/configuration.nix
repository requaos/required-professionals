{
  inputs,
  pkgs,
  lib,
  ...
}: let
  kernel = pkgs.linuxPackages_6_12;
  system = "x86_64-linux";
  hardware = inputs.nixos-hardware.nixosModules;
  # Theme
  themeName = "circuit";
in {
  nixpkgs = {
    hostPlatform = system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "olm-3.2.16"
        "openssl-1.1.1w"
        "electron-32.3.3"
        "electron-25.9.0"
        "electron-21.4.0"
        "electron-12.2.3"
        "archiver-3.5.1"
        "dotnet-sdk-7.0.410"
        "jitsi-meet-1.0.8043"
        "dotnet-core-combined"
        "qtwebkit-5.212.0-alpha4"
        "dotnet-sdk-wrapped-7.0.410"
        "dotnet-wrapped-combined"
        "dotnet-combined"
      ];
    };
  };
  imports = [
    hardware.common-pc-ssd
    hardware.common-pc-laptop
    hardware.common-cpu-intel
    # contains your disk format and partitioning configuration.
    # ../../modules/disko.nix
    # this file is shared among all machines
    ../../modules/shared.nix
    # enables GNOME desktop (optional)
    # ../../modules/gnome.nix
    ../../modules/networking/dns.nix
    ../../modules/networking/vmBridge.nix
    ../../modules/networking/vpn.nix
    ../../modules/sound/pipewire.nix
    ../../modules/physical/touch.nix
    ./home.nix
  ];
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "25.05";

  # This is your user login name.
  users.users.req = {
    name = "req";
    isNormalUser = true;
    createHome = true;
    extraGroups = [
      "libvirtd"
      "docker"
      "adbusers"
    ];
  };

  # Set this for clan commands use ssh i.e. `clan machines update`
  # If you change the hostname, you need to update this line to root@<new-hostname>
  # This only works however if you have avahi running on your admin machine else use IP
  clan.core.networking.targetHost = "root@buukobox";

  # You can get your disk id by running the following command on the installer:
  # Replace <IP> with the IP of the installer printed on the screen or by running the `ip addr` command.
  # ssh root@<IP> lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT
  # disko.devices.disk.main.device = "/dev/disk/by-id/__CHANGE_ME__";

  # IMPORTANT! Add your SSH key here
  # e.g. > cat ~/.ssh/id_ed25519.pub
  users.users.root.openssh.authorizedKeys.keys = [
    ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9o9hlgYeTsKtnfL5ikfe1XxWWlZv6sfhORhciIp8mtPpsZkdE9aNGbXz5a+fsI3RyYdG+wWasvEuo3Q8V7SMGmbnQxIYpn9EtRH46A1dMtqwYM0Vot1Pddaw8moK3RoN0HhLO9ngsA/QX/a5FUeg+aXEzuFb4mJMBD9IBnYqyU0PdEYVZQGc87gENGvemf+7OwefbxJni9ruUpFkRogZCOwer4xwH1C7Ckf/rIv/PrR6Q0yIBmgeAjNP4aJQOyW/g3ezhbSZ89bC0DXWozr1GmhRjjucRQztOSlf/1t6S92IUUj3hyWbh3MvGyhnp4LRJIJGrYURDK7SgywSNcmmaKkWxr476PKt4m2g0FMadwXpHjNu6+vOgOoUNVTL7+qO4n4LNE7iSz+Vj+pghzho/OA3hf8y5jJNZ5Zbtffsw5mYXBNSOSrs7eQ1G5kD7Y/aX3L6zvXmfs9GYpBArIFmhMBkHnxd2iN5ekIrQrXJ/1taOakNMq3tU2wqpR7Y4EFM= req@buukobox
    ''
  ];
  security = {
    rtkit.enable = true;
    pki.certificates = [
      ''
        -----BEGIN CERTIFICATE-----
        MIIDDTCCAfWgAwIBAgIJAPj8SAqyDm3uMA0GCSqGSIb3DQEBCwUAMBQxEjAQBgNV
        BAMTCWxvY2FsaG9zdDAeFw0yNDA4MjcxNTAzNDBaFw0yNTA4MjcxNTAzNDBaMBQx
        EjAQBgNVBAMTCWxvY2FsaG9zdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
        ggEBAM2H2gFMDNXfESvNqbfMiU+E1AkH8Nl8zAKzkCFu2+bSCNib5hlCwxB2t/Ws
        /y+HhTh9YG7z7v+dzn0FnOP2ZKj5JhVPXt01V1G0kAaHUdfwEa/o9QbRykweTemu
        RyQ43K/RUdeZNISWXQ77jHgaOqytpTRFiSRePgbpwCMXQuvf6a/iBcqBMajEfqhF
        VfLs7Rtm8jFa6kE+aeDVFQuiz2a5/IcrFgrAuQXOab+yIqBYf0bvtrnTqlTUa6P2
        sfHIQ0fijv45I7ao78GgjNySDksEbf5mI6sRZQyvnlg6W+SkA/cPZTX9X0/9kfTS
        BVaJYPRIMNSPtlh0nxMbiAi8sa0CAwEAAaNiMGAwDAYDVR0TAQH/BAIwADAOBgNV
        HQ8BAf8EBAMCBaAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwEwFwYDVR0RAQH/BA0w
        C4IJbG9jYWxob3N0MA8GCisGAQQBgjdUAQEEAQIwDQYJKoZIhvcNAQELBQADggEB
        AL4GAelgu8kfT0gnjBJQxtS3vu+Ygubwz5iNvsYj2wUMNH3TSbIkhrD8CdwtrqcM
        YXdZ9N+7t343R5VGkKzOluBnxdwY8PxSsGcvtjopjKatiphPh4UPXtF2j8Bh7p2A
        7c2AAAV+HwKhO9FWYRThtvyYR0XJL5RX8k3A2yQvM6iaQLjC85m0hnsK+Fa/xBeQ
        hcsYcJFG/R2idFDuK2X28fhzv4jSSAZzjh2NDhh28AZNk+67J/WQxvYrO3nFhj7s
        WyHldW4I3GledFMhhVzFZt5BzAJA3qT+mXG7eDvUKic7K+zFDcDFv0qOZtX5EFUI
        8BKHh5JUIMP/gR2B+fx/ss8=
        -----END CERTIFICATE-----
      ''
    ];
  };

  # Zerotier needs one controller to accept new nodes. Once accepted
  # the controller can be offline and routing still works.
  clan.core.networking.zerotier.controller.enable = true;
  boot = {
    # LTS kernel:
    kernelPackages = kernel;
    # defaults to stable kernel when unset

    # nested virtualization in qemu/kvm
    extraModprobeConfig = "options kvm_intel nested=1";

    # virtualization module
    kernelModules = ["kvm-intel"];

    initrd = {
      systemd = {
        enable = true;
      };
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
        "vfio_pci"
      ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "thunderbolt"
      ];

      # root disk encryption
      luks = {
        devices = {
          "root" = {
            device = "/dev/disk/by-uuid/0463b269-67b8-4fd2-a9d1-a60d244ef12e";
          };
        };
      };
    };

    # enable vfio
    kernelParams = [
      # Pretty Boot
      "quiet"
      # enable IOMMU
      "intel_iommu=on"
      #"module_blacklist=i915" # in bios it's set to only use the nvidia gpu

      # acpi_backlight=none allows the backlight save/load systemd service to work.
      # "acpi_backlight=none"
      "acpi_osi=Linux"

      # #isolate the GPU
      # ("vfio-pci.ids="
      # + cell.lib.concatStringsSep "," [
      # "10de:2438" # Graphics
      # "10de:2288" # Audio
      # ])
    ];

    # Fancy Boot
    plymouth = {
      extraConfig = ''
        DeviceScale=4
      '';
    };
    # Quiet boot so that plymouth animations look sweet and seemless, disable or modify here for debugging hardware issues
    # 7 = Debug
    # 6 = Info
    # 5 = Notice
    # 4 = Warn
    # 3 = Err
    # 2 = Crit
    # 1 = Alert
    # 0 = Emerg
    consoleLogLevel = 1;

    plymouth = {
      enable = true;
      theme = themeName;
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [
            themeName
          ];
        })
      ];
    };

    # used for cross-compiling for aarch64.
    # https://github.com/nix-community/nixos-generators#cross-compiling
    binfmt.emulatedSystems = ["aarch64-linux"];
  };
  environment = {
    variables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = "0.5";
      _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2 -Dawt.useSystemAAFontSettings=lcd";
      # Necessary to correctly enable va-api (video codec hardware
      # acceleration). If this isn't set, the libvdpau backend will be
      # picked, and that one doesn't work with most things, including
      # Firefox.
      LIBVA_DRIVER_NAME = "nvidia";
      # Apparently, without this nouveau may attempt to be used instead
      # (despite it being blacklisted)
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # Hardware cursors are currently broken on nvidia
      WLR_NO_HARDWARE_CURSORS = "1";

      # Required to use va-api it in Firefox. See
      # https://github.com/elFarto/nvidia-vaapi-driver/issues/96
      MOZ_DISABLE_RDD_SANDBOX = "1";
      # It appears that the normal rendering mode is broken on recent
      # nvidia drivers:
      # https://github.com/elFarto/nvidia-vaapi-driver/issues/213#issuecomment-1585584038
      NVD_BACKEND = "direct";

      # Wayland Compat stuff not currently needed while still on X:
      # # Required for firefox 98+, see:
      # # https://github.com/elFarto/nvidia-vaapi-driver#firefox
      # EGL_PLATFORM = "wayland";
      # # Required to run the correct GBM backend for nvidia GPUs on wayland
      # GBM_BACKEND = "nvidia-drm";
    };
    systemPackages = with pkgs; [
      xorg.xdpyinfo
      xarchiver
      autorandr
      libnotify
      xterm
      xclip
      maim
      pciutils
      file

      gnumake
      gcc
      # Virtualiztion
      virt-manager
      docker-compose
      # Video
      kernel.nvidiaPackages.vulkan_beta
      kernel.nvidia_x11_vulkan_beta
      # Abandonded
      # config.boot.kernelPackages.nvidiabl
      vulkan-tools
      pciutils
      cudatoolkit
      # USB
      thunderbolt
      # Bluetooth
      bluez
      # Audio
      pipewire
      easyeffects
      # pw-viz <-- was cool eGui native rust graph vizualizer, but it broke and isn't
      # maintained, so we should just write lua scripts to auto-set our graphs without
      # needing a visual interface.
      # see buukubox environment.nix for lua script example for setting graph rules on boot:
      # use `pw-cli ls` to list the current graph for references in your lua scripts.
      wireplumber
      # utilities to support pulseaudio stuff under pipewire
      pulseaudio
      pamixer
      pavucontrol
      # alsa stuff
      alsa-utils

      # coms
      mumble
      # Corporate Coms
      slack
      zoom-us
      lens
      # gimp-with-plugins
      inkscape-with-extensions
      flowblade

      # Games
      lutris
      protonup-qt
      protontricks
      winetricks
      xivlauncher
      gamescope
      scanmem
      libselinux
      proton-caller
      # jdk
      wine64
      # jdk8
      # retroarchFull
      # libretro.parallel-n64
      vulkan-tools
      #(lutris.override {
      # extraPkgs = pkgs: [
      #   innoextract
      #   p7zip
      #   SDL2
      #   SDL2_ttf
      #   SDL2_gfx
      #   SDL2_image
      #   SDL2_mixer
      #   SDL2_net
      #   winetricks
      #   lib32-vulkan-intel
      # ];
      #})
    ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ffae4d62-edb8-41a5-ade9-dd371490ebd8";
      fsType = "btrfs";
      options = ["subvol=@"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/EA31-5359";
      fsType = "vfat";
    };
  };
  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;

    nvidia = {
      nvidiaSettings = true;
      package = kernel.nvidiaPackages.vulkan_beta;
      open = true;
      # only needed for optimus-enabled configurations, conflicts with modesetting driver for displaylink
      modesetting.enable = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true; # for wine with openGL
      extraPackages = with pkgs; [
        kernel.nvidiaPackages.vulkan_beta
        kernel.nvidia_x11_vulkan_beta
      ];
    };
    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };
  };
  networking = {
    useNetworkd = lib.mkForce false;
    useDHCP = lib.mkForce true;
    networkmanager = {
      enable = lib.mkForce true;

      # Non-Random MAC Address
      wifi.scanRandMacAddress = lib.mkForce false;
    };
    firewall = {
      enable = lib.mkForce true;
    };
  };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMFFull.override {
              secureBoot = true;
              tpmSupport = true;
            })
          .fd
          ];
        };
      };
    };
    spiceUSBRedirection.enable = true;
    oci-containers.backend = "docker";
    docker = {
      enable = true;
      enableOnBoot = true;
      # enableNvidia = true;
      storageDriver = "btrfs";
      # logDriver = "journald";
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
    };
  };
  programs = {
    # android adb server
    adb.enable = true;
    # required for easyeffects settings to save correctly.
    dconf.enable = true;
    i3lock = {
      package = pkgs.i3lock-color;
    };
    thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
    gamescope = {
      enable = true;
      env = {
        # unsure if these are really needed when nvidia gpu is set
        # to always-on, rather than optimus/prime dual-gpu mode.
        #__NV_PRIME_RENDER_OFFLOAD = "1";
        #__VK_LAYER_NV_optimus = "NVIDIA_only";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };
  systemd = {
    extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';
    user.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';
    services = {
      nvidia-control-devices = {
        wantedBy = ["multi-user.target"];
        serviceConfig.ExecStart = "${kernel.nvidiaPackages.vulkan_beta.bin}/bin/nvidia-smi";
      };
    };
  };
  qt = {
    platformTheme = "gtk2";
  };
  services = {
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad.clickMethod = "clickfinger";
    };
    displayManager.defaultSession = "i3";
    tumbler.enable = true;
    gvfs.enable = true;
    xserver = {
      enable = true;
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
      # host-based hardwareProfile is the appropriate place to set drivers.
      videoDrivers = [
        "nvidia"
        #"modesetting"
      ];
      dpi = 144;
      displayManager = {
        lightdm = {
          greeters = {
            slick = {
              enable = true;
              theme = {
                name = "Adwaita-Dark";
              };
            };
            gtk = {
              enable = false;
            };
          };
        };
        session = [
          {
            name = "i3";
            manage = "desktop";
            start = ''exec $HOME/.xsession'';
          }
        ];
        sessionCommands = ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
          Xft.dpi: 144
          EOF
        '';
      };
    };
    blueman = {
      enable = true;
    };
    hardware.bolt.enable = true;
    udev = {
      extraRules = ''
        # Always authorize thunderbolt connections when they are plugged in.
        # This is to make sure the USB hub of Thunderbolt is working.
        ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"

        # Screens on boot
        ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.autorandr}/bin/autorandr -c"
      '';
    };
    fwupd = {
      enable = true;
    };
    thermald = {
      enable = true;
    };
    fstrim = {
      enable = true;
    };
  };
}
