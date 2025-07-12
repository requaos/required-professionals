{
  inputs,
  pkgs,
  lib,
  ...
}: let
  kernel = pkgs.linuxPackages_6_12;
  system = "x86_64-linux";
  extensions = inputs.nix-vscode-extensions.extensions.${system};
  home-manager = inputs.home-manager.packages.${system}.nixosModules.home-manager;
  fromYaml = import "${inputs.from-yaml}/fromYaml.nix" {inherit lib;};
  # Theme
  themeName = "circuit";
  colors = fromYaml (builtins.readFile "${inputs.base16-schemes}/onedark.yaml");
  background = colors.base00; #base01???
  indicator = colors.base0B; # what is this? it's green...
  text = colors.base05;
  urgent = colors.base08;
  unfocused = colors.base02; #base03;
  focused = colors.base02; #base0A;
  mod = "Mod4";
  fonts = {
    names = ["Hack Nerd Font"];
    size = 12.0;
  };
  # Convenience
  openWithTerminal = cmd: ''alacritty --command ${cmd}'';
  openWithFileManager = path: ''dbus-send --session --dest=org.freedesktop.FileManager1 --type=method_call /org/freedesktop/FileManager1 org.freedesktop.FileManager1.ShowFolders array:string:"file://${path}" string:""'';
  openWithStorageViewer = path: ''baobab ${path}'';
  nethogsPath = "/run/wrappers/bin/nethogs";
  # Virtual machine networking
  bridgeName = "br0";
  hostInterface = "wlp0s20f3";
in {
  imports = with inputs.nixos-hardware.packages.${system}.nixosModules; [
    common-pc-ssd
    common-pc-laptop
    common-cpu-intel
    # contains your disk format and partitioning configuration.
    # ../../modules/disko.nix
    # this file is shared among all machines
    ../../modules/shared.nix
    # enables GNOME desktop (optional)
    ../../modules/gnome.nix
  ];
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # This is your user login name.
  users.users.user = {
    name = "req";
    extraGroups = [
      "libvirtd"
      "docker"
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
    pam.services =
      lib.attrsets.genAttrs [
        "sudo"
        "i3lock"
        "lightdm"
        "login"
        "xscreensaver"
        "swaylock"
        "gdm"
      ]
      (name: {
        fprintAuth = lib.mkForce true;
        enable = lib.mkForce true;
      });
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
    wrappers = {
      nethogs = {
        source = "${inputs.nixpkgs.nethogs}/bin/nethogs";
        capabilities = "cap_net_admin,cap_net_raw=ep";
        owner = "root";
        group = "root";
      };
    };
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
      # Network
      nethogs
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
      extraPackages = with inputs.nixpkgs; [
        kernel.nvidiaPackages.vulkan_beta
        kernel.nvidia_x11_vulkan_beta
      ];
    };
    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };
  };
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    sharedModules = [
      {
        programs.i3status-rust = {
          bars = {
            default = {
              # theme = "modern";
              # icons = "awesome6";
              settings = {
                theme = {
                  theme = "plain"; # plain | semi-native | native
                };
                icons = {
                  icons = "material-nf";
                };
              };
              blocks =
                [
                  {
                    block = "custom";
                    command = "cat /etc/hostname";
                    interval = "once";
                  }
                  {
                    block = "custom";
                    command = "uname | $\"($in.kernel-name) ($in.kernel-release)\"";
                    interval = "once";
                  }
                  {
                    block = "cpu";
                    interval = 5;
                    click = [
                      {
                        button = "left";
                        cmd = openWithTerminal "htop --sort-key=PERCENT_CPU";
                      }
                    ];
                  }
                  {
                    block = "memory";
                    format = " $icon $mem_used_percents ";
                    interval = 5;
                    click = [
                      {
                        button = "left";
                        cmd = openWithTerminal "htop --sort-key=PERCENT_MEM";
                      }
                    ];
                  }
                  {
                    block = "nvidia_gpu";
                    format = " $icon $utilization $memory ";
                    interval = 5;
                    click = [
                      {
                        button = "left";
                        cmd = "nvidia-settings";
                      }
                    ];
                  }
                  {
                    block = "net";
                    device = "wlp0s20f3";
                    icons_format = "{icon}";
                    format = " ^icon_net_down $speed_down.eng(prefix:K) / ^icon_net_up $speed_up.eng(prefix:K) ";
                    interval = 30;
                    click = [
                      {
                        button = "left";
                        cmd = openWithTerminal "sudo ${nethogsPath}";
                      }
                    ];
                    icons_overrides = {
                      net_wired = "";
                    };
                  }
                ]
                ++ (
                  forEach [
                    "/"
                  ]
                  (path: {
                    inherit path;
                    block = "disk_space";
                    format = " $icon $percentage ";
                    info_type = "used";
                    alert = 90;
                    warning = 75;
                    interval = 60;
                    click = [
                      {
                        button = "left";
                        cmd = openWithFileManager "${path}";
                      }
                      {
                        button = "right";
                        cmd = openWithStorageViewer "${path}";
                      }
                    ];
                  })
                )
                ++ [
                  # https://github.com/greshake/i3status-rust/blob/v0.22.0/doc/blocks.md#music
                  # {
                  #   block = "music";
                  # }
                  {
                    block = "backlight";
                    format = " $icon $brightness";
                    # hide this block if no backlight controls available
                    missing_format = "";
                  }
                  {
                    block = "sound";
                    name = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink";
                    format = " $icon $output_name {$volume|MUTED} ";
                    click = [
                      {
                        button = "left";
                        cmd = ''pw-viz'';
                      }
                    ];
                    step_width = 5;
                    max_vol = 120;
                    headphones_indicator = true;
                    mappings_use_regex = false;
                    mappings = {
                      "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink" = "💻";
                    };
                  }
                  {
                    block = "sound";
                    name = "alsa_output.pci-0000_01_00.1.hdmi-stereo";
                    format = " $icon $output_name {$volume|MUTED} ";
                    click = [
                      {
                        button = "left";
                        cmd = ''pw-viz'';
                      }
                    ];
                    step_width = 5;
                    max_vol = 120;
                    headphones_indicator = true;
                    mappings_use_regex = false;
                    mappings = {
                      "alsa_output.pci-0000_01_00.1.hdmi-stereo" = "📺";
                    };
                  }
                  {
                    block = "sound";
                    device_kind = "source";
                    format = " $icon {$volume|MUTED} ";
                    click = [
                      {
                        button = "left";
                        cmd = ''pw-viz'';
                      }
                    ];
                    step_width = 5;
                    max_vol = 120;
                  }
                  {
                    block = "battery";
                    format = " $icon $percentage {$time |}";
                    # hide this block if no battery on system
                    missing_format = "";
                  }
                  {
                    block = "time";
                    format = " $timestamp.datetime(f:'%a %-m/%d/%Y %-I:%M %p') ";
                    interval = 60;
                  }
                ];
            };
          };
        };
      }
    ];
    users.req = {
      imports = {
        home = {
          packages = with pkgs; [
            # nix
            nix-diff
            # rnix-lsp
            nixpkgs-fmt
            alejandra
            treefmt
            nufmt

            # java
            #jetbrains.jdk

            # fonts
            powerline-fonts
            # tools
            imagemagick
            pango
            zenity
            # surrealist
            # Runtime dependencies for mitmproxy-10.2.1-py3-none-any.whl:
            #       - aioquic not installed
            #mitmproxy

            # editors
            # https://helix-editor.com/
            helix
            # jetbrains.clion

            # .Net
            jetbrains.rider
            (with dotnetCorePackages;
              combinePackages [
                sdk_7_0
                sdk_8_0
                sdk_9_0
              ])
            protobuf

            # java
            #jetbrains.jdk

            # kubernetes
            kubectl
            kubernetes-helm
            cmctl # cert-manager cli
            werf
            argocd

            # iac
            terraform

            # aws
            awscli

            # awscli2 seems to be having some python/font problems, let's check back later since awscli v1 works fine
            #awscli2
            #awslocal
            #aws-mfa
            #terraform
            aws-rotate-key
            _1password-gui
            # fix links
            xdg-utils
            nnn
            xfce.thunar
            xfce.thunar-volman
            xfce.thunar-archive-plugin
            archiver
            # brave
            # chromium
            # firefox
            google-chrome
            # thunderbird
            # thunderbird-wayland
            # thunderbird-bin
            # bitwarden
            # bitwarden-cli
            betterlockscreen
            maim
            #rbw

            # icons for lutris
            dracula-icon-theme

            ## SOCIAL
            discord
            betterdiscordctl
            # zoom-usawds
            # teams
            # jami-client-qt
            # jami-daemon
            # jitsi
            # NOTES AND PRODUCTIVITY
            # super-productivity
            # obsidian
            # notion-app-enhanced
            # logseq
            # appflowy
            # anytype
            # standardnotes
            # gimp
            # vlc
            baobab
            htop

            # nvidia
            nvtop

            # remote
            rustdesk

            # git
            github-desktop
          ];
          file = {
            ".gitignore".text = ''
              .DS_Store
              .DS_Store?
              ._*
              .Spotlight-V100
              .Trashes
              ehthumbs.db
              Thumbs.db
              node_modules
              target

              .idea
              .vscode
              data
            '';

            ".gitattributes".text = ''
              Cargo.lock -diff
              flake.lock -diff
            '';
          };
          pointerCursor = {
            package = pkgs.adwaita-icon-theme;
            name = "Adwaita-Dark";
            gtk.enable = true;
            # size = if meta.scalingFactor <= 1.25 then 16 else 32;
            x11.enable = true;
          };
          # make links work in electron correctly.
          sessionVariables = {
            DEFAULT_BROWSER = "${pkgs.google-chrome}/bin/google-chrome";
          };
          shellAliases = {
            # quick cd
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "....." = "cd ../../../..";
            "......" = "cd ../../../../..";
            # git
            g = "git";
            # grep
            grep = "rg";
            gi = "grep -i";
            # internet ip
            # myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";
            # nix
            n = "nix";
            nepl = "n repl '<nixpkgs>'";
            nr = "n run";
            nd = "n develop";
            ns = "n shell";
            np = "n profile";
            npl = "np list";
            npi = "np install";
            npr = "np remove";
            npu = "np upgrade";
            npua = "npu '.*'";
            nf = "n flake";
            nfu = "nf update";
            nfck = "nf check";
            # bottom
            top = "btm";
            # sudo
            s = "sudo -E ";
            si = "sudo -i";
            se = "sudoedit";
            # systemd
            ctl = "systemctl";
            stl = "s systemctl";
            utl = "systemctl --user";
            ut = "systemctl --user start";
            un = "systemctl --user stop";
            up = "s systemctl start";
            dn = "s systemctl stop";
            jtl = "journalctl";
          };
        };
        xdg = {
          # make xdg links work correctly.
          # enable = true;
          mimeApps = {
            enable = true;
            defaultApplications = {
              "scheme-handler/http" = "google-chrome.desktop";
              "scheme-handler/https" = "google-chrome.desktop";
              "x-scheme-handler/http" = "google-chrome.desktop";
              "x-scheme-handler/https" = "google-chrome.desktop";
              "x-scheme-handler/about" = "google-chrome.desktop";
              "x-scheme-handler/unknown" = "google-chrome.desktop";
              "x-scheme-handler/notion" = "notion-app-enhanced.desktop";
              "text/html" = "google-chrome.desktop";
              "application/pdf" = "google-chrome.desktop";
            };
          };
        };
        systemd = {
          user = {
            services = {
              aws-rotate-key = {
                Unit = {
                  Description = "aws-rotate-key oneshot";
                };
                Service = {
                  Type = "oneshot";
                  ExecStart = "${pkgs.aws-rotate-key}/bin/aws-rotate-key -y -d --profiles default,prod";
                  Restart = "on-failure";
                  RestartSec = "5m";
                };
              };
            };
            timers = {
              aws-rotate-key = {
                Unit = {
                  Description = "aws-rotate-key weekly";
                };
                Timer = {
                  OnCalendar = "weekly";
                  Persistent = true;
                };
                Install = {
                  WantedBy = ["timers.target"];
                };
              };
            };
          };
        };
        services = {
          dunst = {
            enable = true;
            settings = {
              global = {
                font = lib.mkForce "Hack Nerd Font";
                follow = "mouse";
                enable_posix_regex = true;
                #geometry = "300x5-30+50";

                width = "(0,300)";
                height = "200";
                #notification_limit = ;
                origin = "top-right";
                offset = "32x32";
                #scale = "";
                progress_bar = true;
                transparency = 10;
              };
              # urgency_normal = {
              # 	background = "#37474f";
              # 	foreground = "#eceff1";
              # 	timeout = 10;
              # };
            };
          };
          espanso = {
            enable = true;
            matches = {
              "META" = {
                matches = [
                  {
                    trigger = ":shrug";
                    replace = ''¯\_(ツ)_/¯'';
                  }
                  {
                    trigger = ":date";
                    replace = ''{{output}}'';
                    vars = [
                      {
                        name = "output";
                        type = "date";
                        params = {
                          format = "%Y-%m-%d";
                        };
                      }
                    ];
                  }
                  {
                    trigger = ":now";
                    replace = ''{{output}}'';
                    vars = [
                      {
                        name = "output";
                        type = "date";
                        params = {
                          format = "%Y-%m-%dT%H-%M-%S";
                        };
                      }
                    ];
                  }
                ];
              };
            };
          };
          xidlehook = {
            enable = true;
            detect-sleep = true;
            not-when-fullscreen = true;
            # These timings are relative to one another,
            # such that an additional timer here of 10
            # seconds would be triggered 10 seconds
            # After the 600 second trigger has already
            # fired. Seems useful for if I wanted to
            # trigger the blurred background screengrab
            # a few seconds before actually locking for
            # a snappy experience.
            timers = [
              {
                delay = 600;
                command = "exec ${pkgs.betterlockscreen}/bin/betterlockscreen --lock --off 5";
              }
            ];
          };
          clipmenu = {
            enable = true;
          };
          picom.enable = true;
          flameshot.enable = true;
        };
        programs = {
          alacritty.enable = true;
          bash = {
            enable = true;
            bashrcExtra = ''
              source $(blesh-share)/ble.sh
            '';
          };
          i3status-rust = {
            enable = true;
          };
          lazygit.enable = true;
          git = {
            enable = true;
            package = pkgs.gitAndTools.gitFull;
            userName = "Neil Skinner";
            userEmail = "reqpro@requaos.com";
            extraConfig = {
              credential = {
                helper = "libsecret";
              };
              core = {
                autocrlf = "false";
              };
              pull = {
                # https://blog.sffc.xyz/post/185195398930/why-you-should-use-git-pull-ff-only-git-is-a
                #rebase = "true";
                ff = "only";
              };
              push = {
                autoSetupRemote = "true";
              };
            };
          };
          rofi = {
            enable = true;
            terminal = "${pkgs.alacritty}/bin/alacritty";
            theme = ../modules/theme.rasi;
          };
          vscode = {
            enable = true;
            #userSettings = cell.lib.mkForce {};
            profiles.default.extensions =
              (with extensions.open-vsx; [
                jnoortheen.nix-ide
                antyos.openscad
                bierner.markdown-mermaid
                bpruitt-goddard.mermaid-markdown-syntax-highlighting
                christian-kohler.path-intellisense
                gruntfuggly.todo-tree
                kamadorueda.alejandra
                # mhutchie.git-graph
                mkhl.direnv
                moshfeu.compare-folders
                pkief.material-icon-theme
                serayuzgur.crates
                sourcegraph.cody-ai
                tamasfe.even-better-toml
                yzhang.markdown-all-in-one
                zhuangtongfa.material-theme
              ])
              ++ (with extensions.vscode-marketplace; [
                hashicorp.terraform
                humao.rest-client
                jscearcy.rust-doc-viewer
                mitsuhiko.insta
                ms-vsliveshare.vsliveshare

                thenuprojectcontributors.vscode-nushell-lang
              ]);
          };
          nushell = {
            enable = true;
            configFile = {
              source = ../modules/config.nu;
            };
            # envFile = {
            #   source = ./env.nu;
            # };
            package = pkgs.nushell;
            extraEnv = ''
              plugin add ${pkgs.nushellPlugins.polars}/bin/nu_plugin_polars
              # plugin add {pkgs.nushellPlugins.net}/bin/nu_plugin_net # seems to come from unstable and not 24.05
              plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query
              plugin add ${pkgs.nushellPlugins.gstat}/bin/nu_plugin_gstat
              plugin add ${pkgs.nushellPlugins.formats}/bin/nu_plugin_formats
            '';
          };
          direnv = {
            enable = true;
            nix-direnv = {
              enable = true;
            };
            enableNushellIntegration = true;
          };
          starship = {
            enable = true;
            enableNushellIntegration = true;
            settings = {
              character = {
                success_symbol = "[❯](bold purple)";
                error_symbol = "[❯](bold red)";
                vicmd_symbol = "[❮](bold purple)";
              };
              directory.style = "cyan";
              docker_context.symbol = " ";
              git_branch = {
                format = ''[$symbol$branch]($style) '';
                style = "bold dimmed white";
              };
              git_status = {
                format = ''([「$all_status$ahead_behind」]($style) )'';
                conflicted = "⚠";
                ahead = "⟫$count";
                behind = "⟪$count";
                diverged = "🔀";
                stashed = "↪";
                modified = "𝚫";
                staged = "✔";
                renamed = "⇆";
                deleted = "✘";
                style = "bold bright-white";
              };
              haskell.symbol = " ";
              hg_branch.symbol = " ";
              memory_usage = {
                symbol = " ";
                disabled = false;
              };
              nix_shell = {
                format = ''[$symbol$state]($style) '';
                pure_msg = "λ";
                impure_msg = "⎔";
              };
              nodejs.symbol = " ";
              package.symbol = " ";
              python.symbol = " ";
              rust.symbol = " ";
              status.disabled = false;
              add_newline = true;
            };
          };
        };
        gtk = {
          enable = true;
          iconTheme = {
            name = "elementary-Xfce-dark";
            package = pkgs.elementary-xfce-icon-theme;
          };
          theme = {
            name = "zukitre-dark";
            package = pkgs.zuki-themes;
          };
          gtk3.extraConfig = {
            Settings = ''
              gtk-application-prefer-dark-theme=1
            '';
          };
          gtk4.extraConfig = {
            Settings = ''
              gtk-application-prefer-dark-theme=1
            '';
          };
        };
        xsession = {
          enable = true;
          windowManager.i3 = {
            enable = true;
            # package = nixpkgs.i3-gaps;
            config = {
              inherit fonts;
              modifier = mod;
              #menu = "rofi";

              terminal = "alacritty";

              # pressing the current workspace keybind will return to previous workspace
              # workspaceAutoBackAndForth = true;
              workspaceLayout = "tabbed";
              defaultWorkspace = "1";

              startup = [
                # { command = "systemctl --user restart polybar"; always = true; notification = false; }
                # { command = "dropbox start"; notification = false; }
                # { command = "firefox"; workspace = "1: web"; }
              ];

              # assings = {
              #   "1: web" = [{ class = "^Firefox$"; }];
              #   "0: extra" = [{ class = "^Firefox$"; window_role = "About"; }];
              # };
              # output."*".bg = "${stylix.image} fill";

              bars = [
                {
                  statusCommand = "i3status-rs ~/.config/i3status-rust/config-default.toml";
                  fonts = fonts // {size = 10.0;};
                  position = "bottom";
                  # height = "16";
                  # status_padding = 0;
                }
              ];

              # colors = {
              #   inherit background;
              #   urgent = {
              #     inherit background indicator text;
              #     border = urgent;
              #     childBorder = urgent;
              #   };
              #   focused = {
              #     inherit indicator text;
              #     background = focused;
              #     border = focused;
              #     childBorder = focused;
              #   };
              #   focusedInactive = {
              #     inherit background indicator text;
              #     border = unfocused;
              #     childBorder = unfocused;
              #   };
              #   unfocused = {
              #     inherit background indicator text;
              #     border = unfocused;
              #     childBorder = unfocused;
              #   };
              #   placeholder = {
              #     inherit background indicator text;
              #     border = unfocused;
              #     childBorder = unfocused;
              #   };
              # };

              keybindings = lib.mkOptionDefault {
                #"${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
                # "${mod}+space" = "exec ${pkgs.strace}/bin/strace ${nixpkgs.rofi}/bin/rofi -show drun -dpi 0 -theme theme.rasi 2>&1 | ${nixpkgs.gnugrep}/bin/grep theme >> ~/rofi-strace-theme.out";
                "${mod}+space" = "exec ${pkgs.rofi}/bin/rofi -show drun -dpi 0 -theme theme.rasi 2>&1";
                #"${mod}+l" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 222222 & sleep 5 && xset dpms force of'";
                "${mod}+l" = "exec ${pkgs.betterlockscreen}/bin/betterlockscreen --lock --off 5";
                #"Mod4+l" = "exec ${pkgs.betterlockscreen}/bin/betterlockscreen --lock --off 5";
                # migrate to https://github.com/lgmys/savr soon?
                "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";

                # Screenshots
                "Print" = ''exec --no-startup-id maim --format=png | xclip -selection clipboard -t image/png'';
                "${mod}+Print" = ''exec --no-startup-id maim --window $(xdotool getactivewindow) --format=png | xclip -selection clipboard -t image/png'';
                "${mod}+Shift+Print" = ''exec --no-startup-id maim --select --format=png | xclip -selection clipboard -t image/png'';
                "${mod}+Shift+q" = "kill";

                # Applications
                # "Mod4+f" = ''[class="(?i)^firefox$"] focus'';
                # "Mod4+c" = ''[class="(?i)^vscodium$"] focus'';
                # "Mod4+d" = ''[class="(?i)^discord$"] focus'';
                # "Mod4+n" = ''[class="(?i)^notion"] focus'';
                # "Mod4+t" = ''[class="(?i)^alacritty$"] focus'';
                # "Mod4+a" = ''[class="(?i)^alacritty$"] focus'';

                # Focus
                "${mod}+Up" = "focus up";
                "${mod}+Left" = "focus left";
                "${mod}+Right" = "focus right";
                "${mod}+Down" = "focus down";

                # Move
                "${mod}+Shift+Up" = "move up";
                "${mod}+Shift+Left" = "move left";
                "${mod}+Shift+Right" = "move right";
                "${mod}+Shift+Down" = "move down";
                "${mod}+f" = "fullscreen toggle";
                "${mod}+w" = "layout tabbed";

                # Move Workspace
                # "${mod}+Control+Shift+Up" = "move up";
                # "${mod}+Control+Shift+Down" = "move down";
                "${mod}+Control+Shift+Left" = "move workspace to output left";
                "${mod}+Control+Shift+Right" = "move workspace to output right";

                # Laptop Mediakeys:
                # Pulse Audio controls
                "XF86AudioRaiseVolume" = ''exec pamixer --increase 5''; #increase sound volume
                "XF86AudioLowerVolume" = ''exec pamixer --decrease 5''; #decrease sound volume
                "XF86AudioMute" = "exec ${pkgs.bash}/bin/bash -c '[[ `pamixer --get-mute` = \"false\" ]] && pamixer --mute || pamixer --unmute'"; # mute sound
                "XF86AudioMicMute" = "exec ${pkgs.bash}/bin/bash -c '[[ `pamixer --default-source --get-mute` = \"false\" ]] && pamixer --default-source --mute || pamixer --default-source --unmute'"; # mute mic
                # Sreen brightness controls
                "XF86MonBrightnessUp" = ''exec brightnessctl s +5%''; # increase screen brightness
                "XF86MonBrightnessDown" = ''exec brightnessctl s 5%-''; # decrease screen brightness
              };
            };
          };
        };
      };
      home.stateVersion = "25.05";
    };
    backupFileExtension = "bckup";
  };
  networking = {
    useDHCP = lib.mkForce true;
    networkmanager = {
      enable = lib.mkForce true;

      # Non-Random MAC Address
      wifi.scanRandMacAddress = lib.mkForce false;
    };
    firewall = {
      enable = lib.mkForce true;
    };
    # libvirt uses 192.168.122.0
    bridges."${bridgeName}".interfaces = [];
    interfaces."${bridgeName}" = {
      ipv4.addresses = [
        {
          address = "192.168.122.1";
          prefixLength = 24;
        }
      ];
    };
    nat = {
      enable = true;
      internalInterfaces = [bridgeName];
      externalInterface = hostInterface;
      extraCommands = "iptables -t nat -A POSTROUTING -o ${hostInterface} -j MASQUERADE";
    };
    dhcpcd = {
      enable = true;
      allowInterfaces = [bridgeName hostInterface];
      extraConfig = ''
        interface ${bridgeName}
        noipv6rs
        static routers=192.168.122.1
        static broadcast_address=192.168.122.255
        static subnet_mask=255.255.255.0
        static domain_name_servers=1.1.1.1, 8.8.8.8, 208.67.222.222, 1.0.0.1, 8.8.4.4, 208.67.220.220
        static leasetime=-1
        static ip_address=192.168.122.100/24
      '';
    };
  };
  virtualization = {
    libvirtd = {
      enable = true;
      qemu = {
        package = nixpkgs.qemu_kvm;
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
    nvidia-control-devices = {
      wantedBy = ["multi-user.target"];
      serviceConfig.ExecStart = "${kernel.nvidiaPackages.vulkan_beta.bin}/bin/nvidia-smi";
    };
    fprintd = {
      enable = true;
      package = pkgs.fprintd.overrideAttrs {
        mesonCheckFlags = [
          "--no-suite"
          "fprintd:TestPamFprintd"
          "--no-suite"
          "fprintd:TestFprintdUtilsVerify"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceStorageTest"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceStorageClaimedTest"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceNoStorageVerificationTests"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceStorageIdentificationTests"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceClaimedTest"
        ];
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
    pipewire = {
      enable = true;
      audio.enable = true;

      # sound sub-systems:
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
      wireplumber.configPackages = [
        (pkgs.writeTextDir "etc/wireplumber/main.lua.d/91-user-scripts.lua" ''
          load_script("/etc/wireplumber/scripts/auto-connect-ports.lua")
        '')
        (pkgs.writeTextDir "etc/wireplumber/scripts/auto-connect-ports.lua" ''
          -- As explained on: https://bennett.dev/auto-link-pipewire-ports-wireplumber/
          --
          -- This script keeps my stereo-sink connected to whatever output I'm currently using.
          -- I do this so Pulseaudio (and Wine) always sees a stereo output plus I can swap the output
          -- without needing to reconnect everything.

          -- Link two ports together
          function link_port(output_port, input_port)
              if not input_port or not output_port then
                return false
              end

              local link_args = {
                ["link.input.node"] = input_port.properties["node.id"],
                ["link.input.port"] = input_port.properties["object.id"],

                ["link.output.node"] = output_port.properties["node.id"],
                ["link.output.port"] = output_port.properties["object.id"],

                -- The node never got created if it didn't have this field set to something
                ["object.id"] = nil,

                -- I was running into issues when I didn't have this set
                ["object.linger"] = true,

                ["node.description"] = "Link created by auto_connect_ports"
              }

              local link = Link("link-factory", link_args)
              link:activate(1)

              return true
            end

            function delete_link(link_om, output_port, input_port)
              print("Trying to delete")

              if not input_port or not output_port then
                print("No ports")
                return false
              end

              local link = link_om:lookup {
                Constraint {
                  "link.input.node", "equals", input_port.properties["node.id"]
                },
                Constraint {
                  "link.input.port", "equals", input_port.properties["object.id"],
                },
                Constraint {
                  "link.output.node", "equals", output_port.properties["node.id"],
                },
                Constraint {
                  "link.output.port", "equals", output_port.properties["object.id"],
                }
              }

              if not link then

                print("No link!")

                return
              end

              print("Deleting link!")

              link:request_destroy()
            end

            -- Automatically link ports together by their specific audio channels.
            --
            -- ┌──────────────────┐         ┌───────────────────┐
            -- │                  │         │                   │
            -- │               FL ├────────►│ AUX0              │
            -- │      OUTPUT      │         │                   │
            -- │               FR ├────────►│ AUX1  INPUT       │
            -- │                  │         │                   │
            -- └──────────────────┘         │ AUX2              │
            --                              │                   │
            --                              └───────────────────┘
            --
            -- -- Call this method inside a script in global scope
            --
            -- auto_connect_ports {
            --
            --   -- A constraint for all the required ports of the output device
            --   output = Constraint { "node.name"}
            --
            --   -- A constraint for all the required ports of the input device
            --   input = Constraint { .. }
            --
            --   -- A mapping of output audio channels to input audio channels
            --
            --   connections = {
            --     ["FL"] = "AUX0"
            --     ["FR"] = "AUX1"
            --   }
            --
            -- }
            --
            function auto_connect_ports(args)
              local output_om = ObjectManager {
                Interest {
                  type = "port",
                  args["output"],
                  Constraint { "port.direction", "equals", "out" }
                }
              }

              local input_om = ObjectManager {
                Interest {
                  type = "port",
                  args["input"],
                  Constraint { "port.direction", "equals", "in" }
                }
              }

              local all_links = ObjectManager {
                Interest {
                  type = "link",
                }
              }

              local unless = nil

              if args["unless"] then
                unless = ObjectManager {
                  Interest {
                    type = "port",
                    args["unless"],
                    Constraint { "port.direction", "equals", "in" }
                  }
                }

              end

              function _connect()
                local delete_links = unless and unless:get_n_objects() > 0

                print("Delete links", delete_links)

                for output_name, input_name in pairs(args.connect) do
                  local output = output_om:lookup { Constraint { "audio.channel", "equals", output_name } }
                  local input =  input_om:lookup { Constraint { "audio.channel", "equals", input_name } }

                  if delete_links then
                    delete_link(all_links, output, input)
                  else
                    link_port(output, input)
                  end
                end
              end

              output_om:connect("object-added", _connect)
              input_om:connect("object-added", _connect)
              all_links:connect("object-added", _connect)

              output_om:activate()
              input_om:activate()
              all_links:activate()

              if unless then
                unless:connect("object-added", _connect)
                unless:connect("object-removed", _connect)
                unless:activate()
              end
            end

            -- Auto connect the stereo sink to the hdmi center dock screen
            auto_connect_ports {
              output = Constraint { "object.path", "matches", "alsa:pcm:1:hw:sofhdadsp:playback:monitor*" },
              input = Constraint { "port.alias", "matches", "Q2765VC:playback*" },
              connect = {
                ["FL"] = "FL",
                ["FR"] = "FR"
              }
            }
        '')
      ];
      extraConfig = {
        pipewire = let
          json = pkgs.formats.json {};
        in {
          # default audio
          "10-defaults.conf".source = json.generate "10-defaults.conf" {
            context = {
              properties = {
                default.audio.sink = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink";
                default.audio.source = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_6__source";
              };
            };
          };

          # audio crackles fix
          "92-low-latency.conf".source = json.generate "92-low-latency.conf" {
            context = {
              properties = {
                default.clock.rate = 44000;
                default.clock.quantum = 1024;
                default.clock.min-quantum = 1024;
                default.clock.max-quantum = 1024;
              };
            };
          };
        };
        pipewire-pulse = let
          json = pkgs.formats.json {};
        in {
          "92-low-latency.conf".source = json.generate "92-low-latency.conf" {
            context = {
              modules = [
                {
                  name = "libpipewire-module-protocol-pulse";
                  args = {
                    pulse.min.req = "1024/44000";
                    pulse.default.req = "1024/44000";
                    pulse.max.req = "1024/44000";
                    pulse.min.quantum = "1024/44000";
                    pulse.max.quantum = "1024/44000";
                  };
                }
              ];
            };
            stream.properties = {
              node.latency = "1024/44000";
              resample.quality = 1;
            };
          };
        };
      };
    };
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
