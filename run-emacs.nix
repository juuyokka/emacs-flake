{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        run-emacs =
          let
            run-emacs-bin = pkgs.writeShellApplication {
              name = "run-emacs";
              text = ''xwayland-run -geometry 2560x1440 -fullscreen -- emacs'';
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
              exec = "${run-emacs-bin}/bin/run-emacs %F";
              icon = "emacs";
              type = "Application";
              terminal = false;
              categories = [
                "Development"
                "TextEditor"
              ];
              startupWMClass = "Emacs";
            };
          in
          pkgs.symlinkJoin {
            name = "run-emacs";
            paths = [
              run-emacs-bin
              run-emacs-desktop
            ];
          };
      };
    };
}
