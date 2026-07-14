{
  description = "Nix Collection of Programs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = { pkgs, ... }: {
        packages = {
          helium-browser = pkgs.callPackage ./modules/helium-browser { };
          blender = pkgs.callPackage ./modules/blender { };
          gb-studio = pkgs.callPackage ./modules/gb-studio { };
        };
      };
    };
}
