{ pkgs, ... }:
let
  pname = "GB Studio";
  version = "4.3.2";

  deps = with pkgs; [
    glib

    nss
    nspr

    atk
    at-spi2-atk
    gtk3
    pango
    cairo

    alsa-lib

    dbus

    libdrm
    mesa
    expat
    libxkbcommon
    vulkan-loader

    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb

    stdenv.cc.cc.lib
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = "gb-studio";
    desktopName = "GB Studio";
    exec = "gb-studio %U";
    icon = "gb-studio";
    categories = [
      "Network"
      "WebBrowser"
    ];
    terminal = false;
    mimeTypes = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };

  gb-studio = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://github.com/chrismaltby/gb-studio/releases/download/v${version}/gb-studio-linux-debian.deb";
      hash = "sha256-iJqorkHJk/LiNtw3tgxDRl7hNXGfTeDxJvQtg4tqEy4=";
    };

    nativeBuildInputs = with pkgs; [
      dpkg
      makeWrapper
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = deps;

    unpackPhase = ''
      dpkg-deb --fsys-tarfile $src | tar xf - --no-same-permissions
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/opt/gb-studio
      cp -r * $out/opt/gb-studio

      ls -R $out/opt/gb-studio

      makeWrapper $out/opt/gb-studio/usr/bin/gb-studio $out/bin/gb-studio \
        --prefix LD_LIBRARY_PATH : "${
          pkgs.lib.makeLibraryPath (
            with pkgs;
            [
              libGL
              pipewire
              alsa-lib
              libpulseaudio
            ]
          )
        }"

      # Install icon
      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp $out/opt/gb-studio/usr/share/pixmaps/gb-studio.png $out/share/icons/hicolor/256x256/apps/gb-studio.png

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with pkgs.lib; {
      description = "Private, fast, and honest web browser based on ungoogled-chromium";
      homepage = "https://proton.me/mail/";
      license = licenses.gpl3Only;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "gb-studio";
    };
  };
in
gb-studio
