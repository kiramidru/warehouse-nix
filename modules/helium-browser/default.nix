{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      helium-browser = pkgs.callPackage ./package.nix { };
    in
    {
      packages.helium-browser = helium-browser;

      apps.helium-browser = {
        type = "app";
        program = "${helium-browser}/bin/helium";
      };

      devShells.helium-browser = pkgs.mkShell {
        buildInputs = [ helium-browser ];
      };
    };
}
