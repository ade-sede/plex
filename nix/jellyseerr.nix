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
    configDir = "${mountPoint}/jellyseerr";
  };

  systemd.services.jellyseerr-setup = {
    before = ["jellyseerr.service"];
    requiredBy = ["jellyseerr.service"];
    after = ["juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    script = ''
      mkdir -p "${mountPoint}/jellyseerr"
      chmod 755 "${mountPoint}/jellyseerr"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
  };

  systemd.services.jellyseerr = {
    after = ["network.target" "juicefs-mount.service" "jellyseerr-setup.service"];
    requires = ["juicefs-mount.service" "jellyseerr-setup.service"];
    bindsTo = ["juicefs-mount.service"];
  };
}
