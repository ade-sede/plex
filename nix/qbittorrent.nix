{
  config,
  pkgs,
  lib,
  mountPoint,
  qbittorrentWebUIPort,
  qbittorrentDownloadDir,
  qbittorrentWebUIPassword,
  ...
}: let
  # Generate PBKDF2 hash for the password (simplified approach)
  passwordHash = builtins.hashString "sha256" "admin:${qbittorrentWebUIPassword}";
in {
  environment.systemPackages = [
    pkgs.qbittorrent-nox
  ];

  systemd.services.qbittorrent = {
    description = "qBittorrent-nox BitTorrent client";
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];
    wantedBy = ["multi-user.target"];

    preStart = ''
            # Create config directory
            mkdir -p /root/.config/qBittorrent

            # Write config directly inline
            cat > /root/.config/qBittorrent/qBittorrent.conf << 'EOF'
      [BitTorrent]
      Session\QueueingSystemEnabled=false

      [LegalNotice]
      Accepted=true

      [Meta]
      MigrationVersion=8

      [Network]
      Cookies=@Invalid()

      [Preferences]
      WebUI\Enabled=true
      WebUI\LocalHostAuth=false
      WebUI\Port=${toString qbittorrentWebUIPort}
      WebUI\Username=admin
      WebUI\Password_PBKDF2="@ByteArray(${passwordHash})"
      Downloads\SavePath=${qbittorrentDownloadDir}
      General\UseRandomPort=true
      EOF

            # Create download directory
            mkdir -p ${qbittorrentDownloadDir}
    '';

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --confirm-legal-notice --webui-port=${toString qbittorrentWebUIPort} --save-path=${qbittorrentDownloadDir}";
      Restart = "on-failure";
      RestartSec = "5s";
      WorkingDirectory = "/root";
      NoNewPrivileges = true;
    };
  };

  networking.firewall.allowedTCPPorts = [qbittorrentWebUIPort];
}
