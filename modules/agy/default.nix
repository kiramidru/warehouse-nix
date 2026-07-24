{ pkgs, lib, ... }:
let
  pname = "Antigravity CLI";
  version = "4.3.2";

  agy = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.6-6535449645285376/linux-x64/cli_linux_x64.tar.gz";
      hash = "sha256-JEi5ux00lgY6YzXQIdyrkMQtcf2q1jRu+KOV8MoP6dA=";
    };

    sourceRoot = ".";

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 antigravity "$out/bin/agy"
      ln -s agy "$out/bin/antigravity"
      runHook postInstall
    '';

    meta = {
      description = "Google Antigravity agentic coding CLI (`agy`) — repackaged prebuilt binary";
      homepage = "https://antigravity.google/";
      license = lib.licenses.unfree;
      mainProgram = "agy";
    };
  };
in
agy
