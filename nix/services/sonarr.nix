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
    after = ["network.target" "juicefs-mount.service" "qbittorrent.service" "prowlarr.service"];
    requires = ["juicefs-mount.service" "qbittorrent.service" "prowlarr.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    preStart = lib.mkAfter ''
            # Ensure config directory exists
            mkdir -p ${mountPoint}/sonarr

            # Set URL base in Sonarr configuration
            if [ -f ${mountPoint}/sonarr/config.xml ]; then
              ${pkgs.gnused}/bin/sed -i 's|<UrlBase>.*</UrlBase>|<UrlBase>/sonarr</UrlBase>|' ${mountPoint}/sonarr/config.xml
            else
              # Create initial config.xml with URL base
              cat > ${mountPoint}/sonarr/config.xml << 'EOF'
      <?xml version="1.0" encoding="utf-8"?>
      <Config>
        <BindAddress>*</BindAddress>
        <Port>8989</Port>
        <SslPort>9898</SslPort>
        <EnableSsl>False</EnableSsl>
        <LaunchBrowser>False</LaunchBrowser>
        <AuthenticationMethod>None</AuthenticationMethod>
        <AuthenticationRequired>Enabled</AuthenticationRequired>
        <Branch>main</Branch>
        <LogLevel>info</LogLevel>
        <UrlBase>/sonarr</UrlBase>
        <InstanceName>Sonarr</InstanceName>
      </Config>
      EOF
            fi
    '';
  };
}
