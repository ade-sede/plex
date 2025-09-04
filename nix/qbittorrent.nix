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
  # Script to set password via WebUI API after service starts
  setPasswordScript = pkgs.writeShellScript "set-qbt-password.sh" ''
    #!/bin/bash
    # Wait for qBittorrent to start
    sleep 10

    # Try to login and set password via API (localhost bypass)
    COOKIE_FILE=$(mktemp)

    # Login (should work with no password initially due to localhost)
    if ${pkgs.curl}/bin/curl -s -c "$COOKIE_FILE" \
         -d "username=ade-sede&password=" \
         "http://localhost:${toString qbittorrentWebUIPort}/api/v2/auth/login" | grep -q "Ok"; then

      # Set new password
      ${pkgs.curl}/bin/curl -s -b "$COOKIE_FILE" \
           -d "json={\"web_ui_password\":\"${qbittorrentWebUIPassword}\"}" \
           "http://localhost:${toString qbittorrentWebUIPort}/api/v2/app/setPreferences"

      echo "qBittorrent WebUI password set successfully"
    else
      echo "Could not set qBittorrent WebUI password - login failed"
    fi

    rm -f "$COOKIE_FILE"
  '';
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
      WebUI\LocalHostAuth=true
      WebUI\Port=${toString qbittorrentWebUIPort}
      WebUI\Username=ade-sede

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

  # Service to set WebUI password after qBittorrent starts
  systemd.services.qbittorrent-setup = {
    description = "qBittorrent WebUI password setup";
    after = ["qbittorrent.service"];
    requires = ["qbittorrent.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${setPasswordScript}";
    };
  };

  networking.firewall.allowedTCPPorts = [qbittorrentWebUIPort];
}
