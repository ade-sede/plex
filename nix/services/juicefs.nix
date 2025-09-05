{
  config,
  pkgs,
  juiceFsDir,
  dbPath,
  mountPoint,
  BUCKET_URL,
  ACCESS_KEY,
  SECRET_KEY,
  ...
}: let
  juicefs-setup-script = pkgs.writeShellScript "juicefs-setup" ''
    ${pkgs.coreutils}/bin/mkdir -p ${juiceFsDir} && ${pkgs.coreutils}/bin/chown root:root ${juiceFsDir}
    ${pkgs.coreutils}/bin/mkdir -p ${mountPoint} && ${pkgs.coreutils}/bin/chown -R root:juicefs ${mountPoint} && ${pkgs.coreutils}/bin/chmod -R 775 ${mountPoint}
  '';
  juicefs-mount-script = pkgs.writeShellScript "juicefs-mount" ''
    ${pkgs.juicefs}/bin/juicefs mount sqlite3://${dbPath} ${mountPoint} --background
  '';
in {
  systemd.services.juicefs-setup = {
    description = "Setup JuiceFS filesystem";
    wantedBy = [];
    after = ["local-fs.target"];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      RemainAfterExit = true;
      ExecStartPre = [
        "${juicefs-setup-script}"
        "+${pkgs.coreutils}/bin/touch ${dbPath}"
        "+${pkgs.coreutils}/bin/chown root:root ${dbPath}"
      ];
    };
    script = ''
      if ! ${pkgs.juicefs}/bin/juicefs status "sqlite3://${dbPath}" 2>/dev/null; then
        ${pkgs.juicefs}/bin/juicefs format \
          --storage scw \
          --bucket "${BUCKET_URL}" \
          --access-key "${ACCESS_KEY}" \
          --secret-key "${SECRET_KEY}" \
          "sqlite3://${dbPath}" \
          media-center
      fi
    '';
  };

  systemd.services.juicefs-mount = {
    description = "Mount JuiceFS filesystem";
    wantedBy = [];
    after = ["juicefs-setup.service"];
    requires = ["juicefs-setup.service"];
    serviceConfig = {
      Type = "forking";
      User = "root";
      Group = "root";
      Environment = "PATH=/run/wrappers/bin:${pkgs.coreutils}/bin:${pkgs.util-linux}/bin";
      ExecStart = "${juicefs-mount-script}";
      ExecStop = "${pkgs.juicefs}/bin/juicefs umount ${mountPoint}";
      Restart = "always";
      RestartSec = "5";
    };
  };
}
