{ inputs, ... }:

let
  inherit (inputs) wrapper-manager;
in
{
  perSystem =
    { self', pkgs, ... }:
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

                run-emacs.basePackage = self'.packages.run-emacs;
              };
            }
          ];
        };
      };
    };
}
