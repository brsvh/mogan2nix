{
  inputs = {
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils/main";
      inputs.systems.follows = "systems";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        gitignore.follows = "gitignore";
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    systems.url = "github:nix-systems/x86_64-linux/main";
    treefmt = {
      url = "github:numtide/treefmt-nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-utils, nixpkgs, git-hooks, self, treefmt, ... }:
    with builtins;
    with nixpkgs.lib;
    let
      nixos = import ./nixosModules/nixos.nix;
      overlay = import ./pkgs;
      systems = [ "x86_64-linux" ];
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };

        treefmt' = treefmt.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        };

        ourPackages = intersectAttrs (overlay 42 42) pkgs;

        ourPackagesPathList = filter (drv:
          (isDerivation drv) && (meta.availableOn { inherit system; } drv))
          (attrValues ourPackages);
      in {
        checks = {
          formatting = treefmt'.config.build.check self;

          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks.nixfmt.enable = true;
          };
        };

        devShells = {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;

            packages = with pkgs; [ gnutar jq nano ];
          };
        };

        formatter = treefmt'.config.build.wrapper;

        packages = ourPackages // {
          all = pkgs.symlinkJoin rec {
            name = "all";
            paths = ourPackagesPathList;
          };
        };
      }) // {
        overlays.default = final: prev: import overlay final prev;
        nixosModules.nixos = nixos;
      };
}
