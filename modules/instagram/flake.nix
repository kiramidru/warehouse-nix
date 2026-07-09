{
  description = "Hitman 2";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      pname = "instagram-waydroid";
      version = "1.0";

      deps = with pkgs; [
        coreutils
        waydroid
      ];
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        inherit pname version;

        nativeBuildInputs = with pkgs; [
          makeWrapper
        ];

        buildInputs = deps;

        unpackPhase = true;

        installPhase = ''
          mkdir -p $out/bin
          mkdir -p $out/share/instagram

          makeWrapper ${pkgs.waydroid}/bin/waydroid $out/bin/instagram \
            --prefix PATH : ${pkgs.lib.makeBinPath deps} \
            --run '
              if [ ! -d "/var/lib/waydroid" ]; then
                echo "Waydroid not initialized. Please run: sudo waydroid init"
                exit 1
              fi

              if ! waydroid session status | grep -q "RUNNING"; then
                echo "Starting Waydroid session..."
                waydroid session start &
                sleep 3
              fi

              if ! waydroid app list | grep -q "com.instagram.android"; then
                echo "Installing Instagram..."
                waydroid app install '$out'/share/instagram/instagram.apk
              fi

              exec waydroid app launch com.instagram.android
            '
        '';
      };
    };
}
