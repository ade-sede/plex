{
  config,
  pkgs,
  lib,
  mountPoint,
  ...
}: {
  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "${mountPoint}/plex";
    user = "root";
    group = "root";
  };

  systemd.services.plex.after = ["juicefs-mount.service"];
  systemd.services.plex.requires = ["juicefs-mount.service"];
  systemd.services.plex.bindsTo = ["juicefs-mount.service"];
  systemd.services.plex.wantedBy = ["multi-user.target"];
}
