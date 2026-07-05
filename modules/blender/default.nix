{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      b = pkgs.callPackage ./package.nix { };
      mkApp = drv: {
        type = "app";
        program = "${drv}/bin/blender";
      };
      mkDevShell = drv: pkgs.mkShell { buildInputs = [ drv ]; };
    in
    {
      packages = b.versionedBlenders // {
        blender = b.blender;
      };

      apps =
        pkgs.lib.mapAttrs' (name: drv: pkgs.lib.nameValuePair name (mkApp drv)) b.versionedBlenders
        // {
          blender = mkApp b.blender;
        };

      devShells =
        pkgs.lib.mapAttrs' (name: drv: pkgs.lib.nameValuePair name (mkDevShell drv)) b.versionedBlenders
        // {
          blender = mkDevShell b.blender;
        };
    };
}
