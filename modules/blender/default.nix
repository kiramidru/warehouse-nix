{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      blender = pkgs.callPackage ./package.nix { };
    in
    {
      packages.blender = blender;

      apps.blender = {
        type = "app";
        program = "${blender}/bin/blender";
      };

      devShells.blender = pkgs.mkShell {
        buildInputs = [ blender ];
      };
    };
}
