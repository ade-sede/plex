{
  description = "Plex & Jellyfin system configuration";

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
    email = "adrien.de.sede@gmail.com";

    qbittorrentWebUIPort = 8080;
    qbittorrentDownloadDir = "${juiceFsDir}/mountpoint/downloads";

    # SECRETS - Fill these in but NEVER commit them
    BUCKET_URL = "REPLACE_ME";
    ACCESS_KEY = "REPLACE_ME";
    SECRET_KEY = "REPLACE_ME";
    qbittorrentNginxPassword = "REPLACE_ME";
    sonarrNginxPassword = "REPLACE_ME";
  in {
    nixosConfigurations.plex = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit juiceFsDir dbPath mountPoint email BUCKET_URL ACCESS_KEY SECRET_KEY qbittorrentWebUIPort qbittorrentDownloadDir qbittorrentNginxPassword sonarrNginxPassword;
      };
      modules = [
        ./hardware-configuration.nix
        ./nix/system.nix
        ./nix/network.nix
        ./nix/users.nix
        ./nix/sqlite.nix
        ./nix/juicefs.nix
        ./nix/plex.nix
        ./nix/jellyfin.nix
        ./nix/qbittorrent.nix
        ./nix/sonarr.nix
        ./nix/nginx.nix
      ];
    };
  };
}
