{
  config,
  pkgs,
  email,
  qbittorrentWebUIPort,
  HTTP_PASSWORD,
  ...
}: let
  # Create htpasswd file for HTTP auth using openssl
  httpAuth = pkgs.runCommand "http-htpasswd" {} ''
    echo "ade-sede:$(${pkgs.openssl}/bin/openssl passwd -apr1 '${HTTP_PASSWORD}')" > $out
  '';
in {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "plex.ade-sede.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:32400";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
            proxy_set_header X-Plex-Device $http_x_plex_device;
            proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
            proxy_set_header X-Plex-Platform $http_x_plex_platform;
            proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
            proxy_set_header X-Plex-Product $http_x_plex_product;
            proxy_set_header X-Plex-Token $http_x_plex_token;
            proxy_set_header X-Plex-Version $http_x_plex_version;
            proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
            proxy_set_header X-Plex-Provides $http_x_plex_provides;
            proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
            proxy_set_header X-Plex-Model $http_x_plex_model;
          '';
        };
        locations."/torrent/" = {
          proxyPass = "http://127.0.0.1:${toString qbittorrentWebUIPort}/";
          proxyWebsockets = true;
          basicAuth = "qBittorrent Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /torrent;
          '';
        };
        locations."/sonarr/" = {
          proxyPass = "http://127.0.0.1:8989/sonarr/";
          proxyWebsockets = true;
          basicAuth = "Sonarr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /sonarr;
          '';
        };
        locations."/prowlarr/" = {
          proxyPass = "http://127.0.0.1:9696/prowlarr/";
          proxyWebsockets = true;
          basicAuth = "Prowlarr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /prowlarr;
          '';
        };
        locations."/radarr/" = {
          proxyPass = "http://127.0.0.1:7878/radarr/";
          proxyWebsockets = true;
          basicAuth = "Radarr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /radarr;
          '';
        };
        locations."/bazarr/" = {
          proxyPass = "http://127.0.0.1:6767/bazarr/";
          proxyWebsockets = true;
          basicAuth = "Bazarr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /bazarr;
          '';
        };
      };
      "jellyfin.ade-sede.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
          '';
        };
        locations."/torrent/" = {
          proxyPass = "http://127.0.0.1:${toString qbittorrentWebUIPort}/";
          proxyWebsockets = true;
          basicAuth = "qBittorrent Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /torrent;
          '';
        };
        locations."/sonarr/" = {
          proxyPass = "http://127.0.0.1:8989/sonarr/";
          proxyWebsockets = true;
          basicAuth = "Sonarr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /sonarr;
          '';
        };
        locations."/prowlarr/" = {
          proxyPass = "http://127.0.0.1:9696/prowlarr/";
          proxyWebsockets = true;
          basicAuth = "Prowlarr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /prowlarr;
          '';
        };
        locations."/radarr/" = {
          proxyPass = "http://127.0.0.1:7878/radarr/";
          proxyWebsockets = true;
          basicAuth = "Radarr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /radarr;
          '';
        };
        locations."/bazarr/" = {
          proxyPass = "http://127.0.0.1:6767/bazarr/";
          proxyWebsockets = true;
          basicAuth = "Bazarr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Prefix /bazarr;
          '';
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = email;
  };
}
