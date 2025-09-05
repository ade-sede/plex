{
  config,
  pkgs,
  lib,
  mountPoint,
  ...
}: {
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "root";
    group = "root";
    dataDir = "${mountPoint}/radarr";
  };

  systemd.services.radarr = {
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];

    preStart = lib.mkAfter ''
            # Ensure config directory exists
            mkdir -p ${mountPoint}/radarr

            # Set URL base in Radarr configuration
            if [ -f ${mountPoint}/radarr/config.xml ]; then
              ${pkgs.gnused}/bin/sed -i 's|<UrlBase>.*</UrlBase>|<UrlBase>/radarr</UrlBase>|' ${mountPoint}/radarr/config.xml
            else
              # Create initial config.xml with URL base
              cat > ${mountPoint}/radarr/config.xml << 'EOF'
      <?xml version="1.0" encoding="utf-8"?>
      <Config>
        <BindAddress>*</BindAddress>
        <Port>7878</Port>
        <SslPort>9898</SslPort>
        <EnableSsl>False</EnableSsl>
        <LaunchBrowser>False</LaunchBrowser>
        <AuthenticationMethod>None</AuthenticationMethod>
        <AuthenticationRequired>Enabled</AuthenticationRequired>
        <Branch>master</Branch>
        <LogLevel>info</LogLevel>
        <UrlBase>/radarr</UrlBase>
        <InstanceName>Radarr</InstanceName>
      </Config>
      EOF
            fi
    '';
  };
}
