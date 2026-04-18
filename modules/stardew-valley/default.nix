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
        libx11
        libxi
        libxcursor
        libxrandr
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
            autoPatchelfHook
            makeWrapper
            unzip
          ];

          buildInputs = libs;

          desktopItems = [ desktopItem ];

          autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

          unpackPhase = ''
            unzip -q $src -d source || true
            cd source
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/opt/${pname} $out/bin
            cp -r data/noarch/* $out/opt/${pname}/
            chmod -R +w $out/opt/${pname}

            rm -rf $out/opt/${pname}/support
            rm -rf $out/opt/${pname}/yad

            makeWrapper "$out/opt/${pname}/game/StardewValley" "$out/bin/${pname}" \
              --run "cd $out/opt/${pname}/game" \
              --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath libs}:$out/opt/${pname}/game"

            runHook postInstall
          '';

          dontStrip = true;
        };
      };
    };
}
