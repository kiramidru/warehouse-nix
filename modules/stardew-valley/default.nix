{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
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
    in
    {
      packages = {
        stardew-valley = pkgs.stdenv.mkDerivation {
          pname = "stardew-valley";
          version = "1.6.15";

          src = pkgs.fetchurl {
            url = "https://archive.org/download/stardew-valley-linux-gog-phoenix-games-lab/stardew_valley_1_6_15_24357_8705766150_78675.sh";
            sha256 = "sha256-mq50ltEZKJ8WF9apw9dJ83zTLNE+NNMgAVq8LBtVcO8=";
          };

          nativeBuildInputs = with pkgs; [
            makeWrapper
            autoPatchelfHook
            unzip
          ];

          buildInputs = libs;

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

          meta = {
            description = "Stardew Valley 1.6 (GOG version) Native Wrapper";
            mainProgram = "stardew-valley";
          };
        };
      };
    };
}
