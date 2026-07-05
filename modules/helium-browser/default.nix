{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      helium = pkgs.callPackage ./package.nix { };
    in
    {
      packages.default = helium;
      packages.helium = helium;

      apps.default = {
        type = "app";
        program = "${helium}/bin/helium";
      };
      apps.helium = {
        type = "app";
        program = "${helium}/bin/helium";
      };

      devShells.default = pkgs.mkShell {
        buildInputs = [ helium ];
      };
    };
}
