{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils/main";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-utils = {
          follows = "flake-utils";
        };
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    treefmt = {
      url = "github:numtide/treefmt-nix/main";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
  };

  outputs = {
    flake-utils,
    nixpkgs,
    pre-commit-hooks,
    self,
    treefmt,
    ...
  }: let
    nixos = import ./nixosModules/nixos.nix;
    overlay = import ./pkgs;
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            overlay
          ];
        };

        treefmt' = treefmt.lib.evalModule pkgs ({pkgs, ...}: {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
          };
        });

        ourPackages = builtins.intersectAttrs (overlay 42 42) pkgs;

        ourPackagesPathList =
          builtins.filter
          (
            drv:
              (nixpkgs.lib.isDerivation drv)
              && (nixpkgs.lib.meta.availableOn {inherit system;} drv)
          )
          (builtins.attrValues ourPackages);
      in {
        checks = {
          formatting = treefmt'.config.build.check self;

          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
            };
          };
        };

        devShells = {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;

            packages = with pkgs; [
              gnutar
              jq
              nano
            ];
          };
        };

        formatter = treefmt'.config.build.wrapper;

        packages =
          ourPackages
          // {
            all = pkgs.symlinkJoin rec {
              name = "all";
              paths = ourPackagesPathList;
            };
          };
      }
    )
    // {
      overlays.default = overlay;
      nixosModules.nixos = nixos;
    };
}
