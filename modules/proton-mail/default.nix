{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      proton-mail = pkgs.callPackage ./package.nix { };
    in
    {
      packages.proton-mail = proton-mail;

      apps.proton-mail = {
        type = "app";
        program = "${proton-mail}/bin/proton-mail";
      };

      devShells.proton-mail = pkgs.mkShell {
        buildInputs = [ proton-mail ];
      };
    };
}
