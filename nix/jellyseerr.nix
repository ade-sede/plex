{
  config,
  pkgs,
  lib,
  mountPoint,
  ...
}: {
  services.jellyseerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
    package = pkgs.jellyseerr;
  };

  systemd.services.jellyseerr = {
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];
  };
}
