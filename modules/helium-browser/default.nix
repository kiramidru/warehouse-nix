{ pkgs, ... }:
let
  pname = "Helium Browser";
  version = "0.14.3.1";

  deps = with pkgs; [
    pango
    cairo
    expat
    fontconfig
    freetype

    gdk-pixbuf
    glib
    gtk3

    mesa
    libgbm
    libdrm
    libGL
    libvdpau
    libva

    nspr
    nss
    dbus
    systemd

    alsa-lib
    pipewire
    libpulseaudio

    wayland
    vulkan-loader
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = "helium-browser";
    desktopName = "Helium Browser";
    exec = "helium %U";
    icon = "helium";
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

  helium-browser = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64_linux.tar.xz";
      hash = "sha256-mEBKk4+W9Miyu7kr7QQi/WDH4Vkexr1pxNxei2chJ5M=";
    };

    nativeBuildInputs = with pkgs; [
      makeWrapper
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = deps;
    autoPatchelfIgnoreMissingDeps = [
      "libQt6Core.so.6"
      "libQt6Gui.so.6"
      "libQt6Widgets.so.6"
      "libQt5Core.so.5"
      "libQt5Gui.so.5"
      "libQt5Widgets.so.5"
    ];

    dontWrapQtApps = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/opt/helium
      cp -r * $out/opt/helium

      makeWrapper $out/opt/helium/helium $out/bin/helium \
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
        }" \
        --add-flags "--ozone-platform-hint=auto" \
        --add-flags "--enable-features=WaylandWindowDecorations" \
        --add-flags "--disable-component-update" \
        --add-flags "--simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT'" \
        --add-flags "--check-for-update-interval=0" \
        --add-flags "--disable-background-networking"

      # Install icon
      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp $out/opt/helium/product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with pkgs.lib; {
      description = "Private, fast, and honest web browser based on ungoogled-chromium";
      homepage = "https://helium.computer/";
      license = licenses.gpl3Only;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "helium";
    };
  };
in
helium-browser
