{ pkgs, ... }:
let
  pname = "Proton Mail";
  version = "1.13.3";

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
    name = "proton-mail";
    desktopName = "Proton Mail";
    exec = "proton-mail %U";
    icon = "proton-mail";
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
      url = "https://proton.me/download/mail/linux/${version}/ProtonMail-desktop-beta.deb";
      hash = "sha256-ZG3l9QhNtSXjkJ4wa/bJ15Kd7MIgw68tJTPP653HTIg=";
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

      mkdir -p $out/bin $out/opt/proton-mail
      cp -r * $out/opt/proton-mail

      ls -R $out/opt/proton-mail/

      makeWrapper $out/opt/proton-mail/usr/bin/proton-mail $out/bin/proton-mail \
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
      cp $out/opt/proton-mail/usr/share/pixmaps/proton-mail.png $out/share/icons/hicolor/256x256/apps/proton-mail.png

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
      mainProgram = "proton-mail";
    };
  };
in
helium-browser
