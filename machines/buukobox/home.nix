{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  home-manager = inputs.home-manager.nixosModules.home-manager;
  system = "x86_64-linux";
  extensions = inputs.nix-vscode-extensions.extensions.${system};
  fromYaml = import "${inputs.from-yaml}/fromYaml.nix" {inherit lib;};
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
in {
  environment.systemPackages = with pkgs; [
    nethogs
  ];
  security = {
    wrappers = {
      nethogs = {
        source = "${pkgs.nethogs}/bin/nethogs";
        capabilities = "cap_net_admin,cap_net_raw=ep";
        owner = "root";
        group = "root";
      };
    };
  };
  imports = [
    home-manager
    {
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        sharedModules = [
          {
            programs = {
              i3status-rust = {
                enable = true;
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
                        lib.lists.forEach [
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
              alacritty.enable = true;
              bash = {
                enable = true;
                bashrcExtra = ''
                  source $(blesh-share)/ble.sh
                '';
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
                theme = ../../modules/theme.rasi;
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
                  source = ../../modules/config.nu;
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
                nvtopPackages.nvidia

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
                # package = pkgs.i3-gaps;
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
                    # "${mod}+space" = "exec ${pkgs.strace}/bin/strace ${pkgs.rofi}/bin/rofi -show drun -dpi 0 -theme theme.rasi 2>&1 | ${pkgs.gnugrep}/bin/grep theme >> ~/rofi-strace-theme.out";
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
          }
        ];
        users.req = {
          home.stateVersion = "25.05";
        };
        backupFileExtension = "bckup";
      };
    }
  ];
}
