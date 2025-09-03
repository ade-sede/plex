{
  config,
  pkgs,
  juiceFsDir,
  dbPath,
  ...
}: {
  systemd.services.sqlite-setup = {
    description = "Setup SQLite database to track JuiceFS metadata";
    wantedBy = [];
    partOf = ["plex.service"];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      ExecStartPre = [
        "+${pkgs.coreutils}/bin/mkdir -p ${juiceFsDir}"
        "+${pkgs.coreutils}/bin/chown root:root ${juiceFsDir}"
        "+${pkgs.coreutils}/bin/touch ${dbPath}"
        "+${pkgs.coreutils}/bin/chown root:root ${dbPath}"
      ];
      ExecStart = "${pkgs.sqlite}/bin/sqlite3 ${dbPath} 'CREATE TABLE IF NOT EXISTS placeholder (id INTEGER);'";
      RemainAfterExit = true;
    };
    after = ["local-fs.target"];
  };
}
