{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      bun2nix,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      builder = bun2nix.packages.${system}.default;
      ghui-src = pkgs.fetchFromGitHub {
        owner = "kitlangton";
        repo = "ghui";
        rev = "main";
        hash = "sha256-jF6/lBQrPVTUv5UVzswaRnxHBdUwePSEcmSEWH3qaow=";
      };
    in
    {
      packages.${system}.default = builder.mkDerivation {
        src = ghui-src;

        packageJson = "${ghui-src}/package.json";

        bunDeps = builder.fetchBunDeps {
          bunNix = ./bun.nix;
          src = ghui-src;
        };

        bunBuildFlags = [
          "src/index.tsx"
          "--outfile"
          "@kitlangton/ghui"
          "--compile"
          "--minify"
          "--sourcemap"
          "--bytecode"
          "--target"
          "bun"
          "--format"
          "esm"
        ];
      };
    };
}
