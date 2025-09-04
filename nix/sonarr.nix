{
  config,
  pkgs,
  lib,
  mountPoint,
  ...
}: {
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "root";
    group = "root";
    dataDir = "${mountPoint}/sonarr";
  };

  systemd.services.sonarr = {
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];
  };
}
