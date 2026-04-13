{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      mkBlender =
        { version, src }:
        let
          libs =
            with pkgs;
            [
              wayland
              libdecor
              libX11
              libXi
              libxxf86vm
              libxfixes
              libxrender
              libxkbcommon
              libGLU
              libglvnd
              numactl
              SDL2
              libdrm
              ocl-icd
              stdenv.cc.cc.lib
              openal
              alsa-lib
              pulseaudio
            ]
            ++ lib.optionals (lib.versionAtLeast version "3.5") [
              libsm
              libice
              zlib
            ]
            ++ lib.optionals (lib.versionAtLeast version "4.5") [ vulkan-loader ];
        in
        pkgs.stdenv.mkDerivation {
          pname = "blender-bin";
          inherit version src;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            mkdir -p $out/libexec/blender
            cp -r . $out/libexec/blender
            mkdir -p $out/share/applications $out/share/icons/hicolor/scalable/apps

            find $out/libexec/blender -name "*.desktop" -exec mv {} $out/share/applications/ \;
            find $out/libexec/blender -name "*.svg" -exec mv {} $out/share/icons/hicolor/scalable/apps/ \;

            mkdir -p $out/bin
            makeWrapper $out/libexec/blender/blender $out/bin/blender \
              --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${lib.makeLibraryPath libs}"

            patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/libexec/blender/blender
            find $out/libexec/blender -name "python3*" -executable -exec \
              patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" {} \;
          '';
        };

      blenderVersions = {
        "2_82" = {
          version = "2.82a";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz";
          hash = "sha256-+0ACWBIlJcUaWJcZkZfnQBBJT3HyshIsTdEiMk5u3r4=";
        };

        "2_83" = {
          version = "2.83.20";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.83/blender-2.83.20-linux-x64.tar.xz";
          hash = "sha256-KuPyb39J+TUrcPUFuPNj0MtRshS4ZmHZTuTpxYjEFPg=";
        };

        "2_90" = {
          version = "2.90.1";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.1-linux64.tar.xz";
          hash = "sha256-BUZoxGo+VpIfKDcJ9Ro194YHhhgwAc8uqb4ySdE6xmc=";
        };

        "2_91" = {
          version = "2.91.2";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.91/blender-2.91.2-linux64.tar.xz";
          hash = "sha256-jx4eiFJ1DhA4V5M2x0YcGlSS2pc84Yjh5crpmy95aiM=";
        };

        "2_92" = {
          version = "2.92.0";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.92/blender-2.92.0-linux64.tar.xz";
          hash = "sha256-LNF61unWwkGsFLhK1ucrUHruyXnaPZJrGhRuiODrPrQ=";

        };

        "2_93" = {
          version = "2.93.18";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.18-linux-x64.tar.xz";
          hash = "sha256-+H9z8n0unluHbqpXr0SQIGf0wzHR4c30ACM6ZNocNns=";
        };

        "3_0" = {
          version = "3.0.1";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.0/blender-3.0.1-linux-x64.tar.xz";
          hash = "sha256-TxeqPRDtbhPmp1R58aUG9YmYuMAHgSoIhtklTJU+KuU=";
        };

        "3_1" = {
          version = "3.1.2";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.1/blender-3.1.2-linux-x64.tar.xz";
          hash = "sha256-wdNFslxvg3CLJoHTVNcKPmAjwEu3PMeUM2bAwZ5UKVg=";
        };

        "3_2" = {
          version = "3.2.2";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.2/blender-3.2.2-linux-x64.tar.xz";
          hash = "sha256-FyZWAVfZDPKqrrbSXe0Xg9Zr/wQ4FM2VuQ/Arx2eAYs=";
        };

        "3_3" = {
          version = "3.3.21";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.3/blender-3.3.21-linux-x64.tar.xz";
          hash = "sha256-KvaLcca7JOLT4ho+LbOax9c2tseEPASQie/qg8zx8Y0=";
        };

        "3_4" = {
          version = "3.4.1";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.4/blender-3.4.1-linux-x64.tar.xz";
          hash = "sha256-FJf4P5Ppu73nRUIseV7RD+FfkvViK0Qhdo8Un753aYE=";
        };

        "3_5" = {
          version = "3.5.1";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.5/blender-3.5.1-linux-x64.tar.xz";
          hash = "sha256-2Crn72DqsgsVSCbE8htyrgAerJNWRs0plMXUpRNvfxw=";
        };

        "3_6" = {
          version = "3.6.23";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.6/blender-3.6.23-linux-x64.tar.xz";
          hash = "sha256-DpoYr00AYLgl6WF+JKd191ng+fZyccBi89U6U5AwrwA=";
        };

        "4_0" = {
          version = "4.0.2";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.0/blender-4.0.2-linux-x64.tar.xz";
          hash = "sha256-VYOlWIc22ohYxSLvF//11zvlnEem/pGtKcbzJj4iCGo=";
        };

        "4_1" = {
          version = "4.1.1";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.1/blender-4.1.1-linux-x64.tar.xz";
          hash = "sha256-qy6j/pkWAaXmvSzaeG7KqRnAs54FUOWZeLXUAnDCYNM=";
        };

        "4_2" = {
          version = "4.2.15";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.2/blender-4.2.15-linux-x64.tar.xz";
          hash = "sha256-udzB0GhhUpd55/r42Cyd01Y0Q9+x6xQhJCTIxAt3B04=";
        };

        "4_3" = {
          version = "4.3.2";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.3/blender-4.3.2-linux-x64.tar.xz";
          hash = "sha256-TaHJVmc8BIXmMFTlY+5pGYzI+A2BV911kt/8impVkuY=";
        };

        "4_4" = {
          version = "4.4.3";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.4/blender-4.4.3-linux-x64.tar.xz";
          hash = "sha256-jTvgfSvEErUCxr/jz+PiIZWkFkB2hn2ph84UjXPCeUY=";
        };

        "4_5" = {
          version = "4.5.4";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.5/blender-4.5.4-linux-x64.tar.xz";
          hash = "sha256-Lm746Z/DYycnBCndyOe60oWd2HiloTfS4L8PAvZ5JQU=";
        };

        "5_0" = {
          version = "5.0.1";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender5.0/blender-5.0.1-linux-x64.tar.xz";
          hash = "sha256-gBlYDuG3Ji5QX0GWoAI3zPdDyI0gWzjTQgFRBnbmCwk=";
        };
        "5_1" = {
          version = "5.1.0";
          url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender5.1/blender-5.1.0-linux-x64.tar.xz";
          hash = "sha256-fyR1mQYTyNTHrFaXgD/PQNCVQcH9jCOTb0sHoWmpIMc=";
        };
      };
    in
    {
      packages =
        let
          versionedBlenders = lib.mapAttrs' (
            name: info:
            lib.nameValuePair "blender_${name}" (mkBlender {
              version = info.version;
              src = pkgs.fetchurl {
                url = info.url;
                sha256 = info.hash;
              };
            })
          ) blenderVersions;
        in
        versionedBlenders
        // {
          blender = versionedBlenders.blender_5_1;
        };
    };
}
