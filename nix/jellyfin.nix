{
  config,
  pkgs,
  lib,
  mountPoint,
  ...
}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  systemd.services.jellyfin = {
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];

    serviceConfig = {
      StateDirectory = lib.mkForce "${mountPoint}/jellyfin";
      CacheDirectory = lib.mkForce "${mountPoint}/jellyfin-cache";
    };

    environment = {
      JELLYFIN_DATA_DIR = "${mountPoint}/jellyfin";
      JELLYFIN_CACHE_DIR = "${mountPoint}/jellyfin-cache";
      LD_LIBRARY_PATH = "/run/opengl-driver/lib";
    };
  };
}
