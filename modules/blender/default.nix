{ lib, pkgs, ... }:
let
  pname = "Blender";
  version = "5.1.2";

  deps = with pkgs; [
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
    libsm
    libice
    zlib
    vulkan-loader
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = "blender";
    desktopName = "Blender";
    exec = "blender %f";
    icon = "blender";
    terminal = false;
    categories = [
      "Graphics"
      "3DGraphics"
    ];
    mimeTypes = [ "application/x-blender" ];
  };

  blender = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://download.blender.org/release/Blender5.1/blender-${version}-linux-x64.tar.xz";
      hash = "sha256-qsyzVfUBg5ebaYvM50ZxA6diYbX6WfSXIpWEJmKihfs=";
    };

    nativeBuildInputs = with pkgs; [
      makeWrapper
      copyDesktopItems
      patchelf
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/libexec/blender
      cp -r . $out/libexec/blender

      mkdir -p $out/bin
      makeWrapper $out/libexec/blender/blender $out/bin/blender \
        --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${lib.makeLibraryPath deps}"

      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/libexec/blender/blender
      find $out/libexec/blender -name "python3*" -executable -exec \
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" {} \;

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = {
      description = "3D creation suite";
      homepage = "https://www.blender.org/";
      license = lib.licenses.gpl3Plus;
      platforms = [ "x86_64-linux" ];
      mainProgram = "blender";
    };
  };
in
blender
