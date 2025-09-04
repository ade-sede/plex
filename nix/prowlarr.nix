{
  config,
  pkgs,
  lib,
  mountPoint,
  ...
}: {
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        port = 9696;
        urlbase = "/prowlarr";
        bindaddress = "*";
      };
      update = {
        mechanism = "external";
        automatically = false;
      };
      log = {
        analyticsEnabled = false;
      };
    };
  };

  systemd.services.prowlarr = {
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];

    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "root";
      Group = "root";
      StateDirectory = lib.mkForce "prowlarr";
      ExecStart = lib.mkForce "${lib.getExe config.services.prowlarr.package} -nobrowser -data=${mountPoint}/prowlarr";
    };

    preStart = lib.mkAfter ''
      mkdir -p ${mountPoint}/prowlarr
      chown root:root ${mountPoint}/prowlarr
    '';
  };
}
