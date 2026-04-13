{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "stardew-valley";
      version = "1.6.15";

      libs = with pkgs; [
        stdenv.cc.cc.lib
        libGL
        libglvnd
        libX11
        libXi
        libXcursor
        libXrandr
        libxkbcommon
        alsa-lib
        libpulseaudio
        udev
        zlib
        openal
        SDL2
        lttng-ust
        fontconfig
        libxft
        libcap
        icu
        openssl
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "Stardew Valley";
        exec = "stardew-valley";
        icon = "stardew-valley";
        comment = "An open-ended country-life RPG";
        desktopName = "Stardew Valley";
        genericName = "Stardew Valley";
        categories = [ "Game" ];
      };
    in
    {
      packages = {
        stardew-valley = pkgs.stdenv.mkDerivation {
          inherit pname version;

          src = pkgs.fetchurl {
            url = "https://archive.org/download/stardew-valley-linux-gog-phoenix-games-lab/stardew_valley_1_6_15_24357_8705766150_78675.sh";
            sha256 = "sha256-mq50ltEZKJ8WF9apw9dJ83zTLNE+NNMgAVq8LBtVcO8=";
          };

          nativeBuildInputs = with pkgs; [
            makeWrapper
            autoPatchelfHook
            unzip
            copyDesktopItems
          ];

          buildInputs = libs;
          desktopItems = [ desktopItem ];

          autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

          unpackPhase = ''
            ${pkgs.unzip}/bin/unzip -q $src -d source || true
            cd source
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/opt/stardew

            if [ -d "data/noarch/game" ]; then
              cp -r data/noarch/game/. $out/opt/stardew/
            else
              REAL_PATH=$(find . -name "StardewValley" -exec dirname {} \; | head -n 1)
              cp -r $REAL_PATH/. $out/opt/stardew/
            fi

            chmod -R +x $out/opt/stardew/StardewValley
            mkdir -p $out/share/icons/hicolor/256x256/apps
            find $out/opt/stardew -name "StardewValley.png" -exec cp {} $out/share/icons/hicolor/256x256/apps/stardew-valley.png \;

            if [ ! -f $out/share/icons/hicolor/256x256/apps/stardew-valley.png ]; then
               cp $out/opt/stardew/icon.png $out/share/icons/hicolor/256x256/apps/stardew-valley.png || true
            fi

            mkdir -p $out/libexec
            echo "#!/bin/sh" > $out/libexec/sw_vers
            chmod +x $out/libexec/sw_vers
            mkdir -p $out/bin
            makeWrapper $out/opt/stardew/StardewValley $out/bin/stardew-valley \
              --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${lib.makeLibraryPath libs}" \
              --prefix PATH : "$out/libexec" \
              --set ALSA_PLUGIN_DIR "${pkgs.alsa-plugins}/lib/alsa-lib"

            runHook postInstall
          '';
        };
      };
    };
}
