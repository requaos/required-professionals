{
  inputs = {
    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    nixpkgs.follows = "clan-core/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    from-yaml = {
      url = "github:pegasust/fromYaml";
      flake = false;
    };

    base16-schemes = {
      url = "github:base16-project/base16-schemes";
      flake = false;
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    clan-core,
    ...
  }: let
    # Usage see: https://docs.clan.lol
    clan = clan-core.lib.buildClan {
      inherit self;
      # Ensure this is unique among all clans you want to use.
      meta.name = "requaos";

      # Debug info for now
      specialArgs = {
        inherit inputs;
        nixpkgs = {
          config = {
            debug = true;
            keepDebugInfo = true;
            allowUnfree = true;
          };
        };
      };

      # All machines in ./machines will be imported.

      # Prerequisite: boot into the installer.
      # See: https://docs.clan.lol/getting-started/installer
      # local> mkdir -p ./machines/machine1
      # local> Edit ./machines/<machine>/configuration.nix to your liking.
      machines = {
        # You can also specify additional machines here.
        # somemachine = {
        #  imports = [ ./some-machine/configuration.nix ];
        # }
      };
    };
  in {
    inherit (clan) nixosConfigurations clanInternals;
    # Add the Clan cli tool to the dev shell.
    # Use "nix develop" to enter the dev shell.
    devShells =
      clan-core.inputs.nixpkgs.lib.genAttrs
      [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ]
      (system: {
        default = clan-core.inputs.nixpkgs.legacyPackages.${system}.mkShell {
          packages = [clan-core.packages.${system}.clan-cli];
        };
      });
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
