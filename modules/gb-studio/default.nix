{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      gb-studio = pkgs.callPackage ./package.nix { };
    in
    {
      packages.gb-studio = gb-studio;

      apps.gb-studio = {
        type = "app";
        program = "${gb-studio}/bin/gb-studio";
      };

      devShells.gb-studio = pkgs.mkShell {
        buildInputs = [ gb-studio ];
      };
    };
}
