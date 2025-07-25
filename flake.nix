{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nil,
    }:
    let
      inherit (nix-darwin.lib) darwinSystem;
      username = "yoichiroito";
    in
    {
      darwinConfigurations = {
        MBA-2025-M4 = darwinSystem {
          specialArgs = inputs;
          system = "aarch64-darwin";
          modules = [
            (import ./hosts/MBA-2025-M4/configuration.nix {
              inherit self username;
            })
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = (
                import ./home.nix {
                  inherit username;
                  stateVersion = "24.11";
                }
              );
            }
          ];
        };
        MBP-2022-M1 = darwinSystem {
          specialArgs = inputs;
          system = "aarch64-darwin";
          modules = [
            (import ./hosts/MBP-2022-M1/configuration.nix {
              inherit self username;
            })
            home-manager.darwinModules.home-manager
            {
              home-manager.backupFileExtension = "backup";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home.nix {
                inherit username;
                stateVersion = "22.05";
              };
            }
          ];
        };
        MBP-2025-M4 =
          let
            system = "aarch64-darwin";
          in
          darwinSystem rec {
            specialArgs = inputs;
            inherit system;
            modules = [
              (import ./hosts/MBP-2025-M4/configuration.nix {
                inherit self username;
              })
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./home.nix {
                  inherit username;
                  stateVersion = "24.11";
                };
              }
            ];
          };
      };
      overlays = {
        nil = final: prev: {
          nil = nil.packages.${prev.stdenv.system}.nil;
        };
      };
    };
}
