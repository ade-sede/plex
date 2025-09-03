{
  description = "Plex system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    juiceFsDir = "/var/lib/juice-fs";
    dbPath = "${juiceFsDir}/metadata.db";
    mountPoint = "${juiceFsDir}/mountpoint";
    domains = ["plex.ade-sede.com"];
    email = "adrien.de.sede@gmail.com";

    # SECRETS - Fill these in but NEVER commit them
    BUCKET_URL = "REPLACE_ME";
    ACCESS_KEY = "REPLACE_ME";
    SECRET_KEY = "REPLACE_ME";
  in {
    nixosConfigurations.plex = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit juiceFsDir dbPath mountPoint domains email BUCKET_URL ACCESS_KEY SECRET_KEY;
      };
      modules = [
        ./hardware-configuration.nix
        ./nix/system.nix
        ./nix/network.nix
        ./nix/users.nix
        ./nix/sqlite.nix
        ./nix/juicefs.nix
        ./nix/plex.nix
        ./nix/nginx.nix
      ];
    };
  };
}
