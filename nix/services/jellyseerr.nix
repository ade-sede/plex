{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: {
  services.jellyseerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
    package = pkgs.jellyseerr;
    configDir = "${JUICE_FS_ROOT}/jellyseerr";
  };

  systemd.services.jellyseerr-setup = {
    before = ["jellyseerr.service"];
    requiredBy = ["jellyseerr.service"];
    after = ["juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    script = ''
      mkdir -p "${JUICE_FS_ROOT}/jellyseerr/logs"
      chmod 755 "${JUICE_FS_ROOT}/jellyseerr"
      sleep 10
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
  };

  systemd.services.jellyseerr = {
    after = ["network.target" "juicefs-mount.service" "jellyseerr-setup.service" "jellyfin.service" "sonarr.service" "radarr.service"];
    requires = ["juicefs-mount.service" "jellyseerr-setup.service" "jellyfin.service" "sonarr.service" "radarr.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];
    serviceConfig = {
      User = lib.mkForce "root";
      Group = lib.mkForce "root";
      PrivateUsers = lib.mkForce false;
    };
  };
}
