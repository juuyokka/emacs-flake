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
      imports = [ inputs.treefmt-nix.flakeModule ];

      systems = [ "x86_64-linux" ];

      perSystem =
        {
          self',
          system,
          pkgs,
          ...
        }:
        {
          packages = {
            emacs = wrapper-manager.lib.build {
              inherit pkgs;
              modules = [
                {
                  wrappers = {
                    emacs = {
                      basePackage = pkgs.emacs30;
                      pathAdd = with pkgs; [
                        nixfmt-rfc-style
                        wl-clipboard
                      ];
                      env = {
                        QT_QPA_PLATFORM.value = "xcb";
                        GDK_BACKEND.value = "x11";
                      };
                    };

                    run-emacs = {
                      basePackage = self'.packages.run-emacs;
                      postBuild = ''
                        mkdir -p $out/share/applications
                        cp ${self'.packages.run-emacs-desktop}/share/applications/exwm.desktop $out/share/applications
                      '';
                    };
                  };
                }
              ];
            };

            run-emacs-desktop = pkgs.makeDesktopItem {
              name = "exwm";
              desktopName = "EXWM";
              genericName = "Text Editor";
              comment = "Emacs X Window Manager";
              mimeTypes = [
                "text/english"
                "text/plain"
                "text/x-makefile"
                "text/x-c++hdr"
                "text/x-c++src"
                "text/x-chdr"
                "text/x-csrc"
                "text/x-java"
                "text/x-moc"
                "text/x-pascal"
                "text/x-tcl"
                "text/x-tex"
                "application/x-shellscript"
                "text/x-c"
                "text/x-c++"
              ];
              exec = "${self'.packages.run-emacs}/bin/run-emacs %F";
              icon = "emacs";
              type = "Application";
              terminal = false;
              categories = [
                "Development"
                "TextEditor"
              ];
              startupWMClass = "Emacs";
            };

            run-emacs = pkgs.writeShellApplication {
              name = "run-emacs";
              text = ''xwayland-run -geometry 2560x1440 -fullscreen -- emacs'';
            };
          };

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
