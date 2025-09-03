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
    serviceConfig = {
      Type = "oneshot";
      User = "plex";
      Group = "plex";
      ExecStartPre = [
        "+${pkgs.coreutils}/bin/mkdir -p ${juiceFsDir}"
        "+${pkgs.coreutils}/bin/chown plex:plex ${juiceFsDir}"
        "+${pkgs.coreutils}/bin/touch ${dbPath}"
        "+${pkgs.coreutils}/bin/chown plex:plex ${dbPath}"
      ];
      ExecStart = "${pkgs.sqlite}/bin/sqlite3 ${dbPath} 'CREATE TABLE IF NOT EXISTS placeholder (id INTEGER);'";
      RemainAfterExit = true;
    };
    after = ["local-fs.target"];
  };
}
