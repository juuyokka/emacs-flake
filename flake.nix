{
  description = "Flake for managing Emacs environment.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    wrapper-manager.url = "github:viperML/wrapper-manager";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs =
    inputs@{ flake-parts, wrapper-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        ./emacs-wrapped.nix
        ./run-emacs.nix
      ];

      systems = [ "x86_64-linux" ];

      perSystem =
        {
          self',
          system,
          pkgs,
          ...
        }:
        {
          devShells = {
            default = pkgs.mkShell {
              packages = [ self'.packages.emacs ];
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.emacs-overlay.overlays.emacs ];
          };
        };
    };
}
