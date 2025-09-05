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
    dataDir = "${mountPoint}/jellyfin";
    cacheDir = "${mountPoint}/jellyfin-cache";
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

    environment = {
      LD_LIBRARY_PATH = "/run/opengl-driver/lib";
    };
  };
}
