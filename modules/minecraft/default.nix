{
  description = "A Minecraft Legacy Launcher";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      runtimeLibs = with pkgs; [
        libx11
        libxext
        libxcursor
        libxrandr
        libxi
        libpulseaudio
        libGL
        libglvnd
        mesa
        vulkan-loader
        udev
        zlib
        flite
      ];
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "legacy-launcher";
        version = "1.0";
        src = builtins.fetchurl {
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz";
          sha256 = "sha256-+0ACWBIlJcUaWJcZkZfnQBBJT3HyshIsTdEiMk5u3r4=";
        };

        buildInputs = with pkgs; [
          makeWrapper
          copyDesktopItems
        ];

        dontUnpack = true;

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "legacy-launcher";
            desktopName = "Legacy Launcher";
            comment = "Minecraft Launcher (Legacy)";
            exec = "legacy-launcher";
            icon = "minecraft";
            categories = [ "Game" ];
          })
        ];

        installPhase = ''
          mkdir -p $out/bin $out/share/legacy-launcher

          cp $src/LegacyLauncher.jar $out/share/legacy-launcher/launcher.jar

          makeWrapper ${pkgs.openjdk21}/bin/java $out/bin/legacy-launcher \
            --add-flags "-Xmx4G -Xms2G -Djava.awt.headless=false -jar $out/share/legacy-launcher/launcher.jar" \
            --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runtimeLibs}:/run/opengl-driver/lib"
        '';
      };
    };
}
