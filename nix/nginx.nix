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
      "media.ade-sede.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/plex/" = {
          proxyPass = "http://127.0.0.1:32400/";
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
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
          '';
        };
        locations."/jellyfin/" = {
          proxyPass = "http://127.0.0.1:8096/";
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
        locations."/jellyseerr" = {
          proxyPass = "http://127.0.0.1:5055"; # NO TRAILING SLASH
          proxyWebsockets = true;
          basicAuth = "Jellyseerr Access";
          basicAuthFile = "${httpAuth}";
          extraConfig = ''
            set $app 'jellyseerr';
            # Remove /jellyseerr path to pass to the app
            rewrite ^/jellyseerr/?(.*)$ /$1 break;
            # Redirect location headers
            proxy_redirect ^ /$app;
            proxy_redirect /setup /$app/setup;
            proxy_redirect /login /$app/login;
            # Sub filters to replace hardcoded paths
            proxy_set_header Accept-Encoding "";
            sub_filter_once off;
            sub_filter_types *;
            sub_filter 'href="/"' 'href="/$app"';
            sub_filter 'href="/login"' 'href="/$app/login"';
            sub_filter 'href:"/"' 'href:"/$app"';
            sub_filter '\/_next' '\/$app\/_next';
            sub_filter '/_next' '/$app/_next';
            sub_filter '/api/v1' '/$app/api/v1';
            sub_filter '/login/plex/loading' '/$app/login/plex/loading';
            sub_filter '/images/' '/$app/images/';
            sub_filter '/imageproxy/' '/$app/imageproxy/';
            sub_filter '/avatarproxy/' '/$app/avatarproxy/';
            sub_filter '/android-' '/$app/android-';
            sub_filter '/apple-' '/$app/apple-';
            sub_filter '/favicon' '/$app/favicon';
            sub_filter '/logo_' '/$app/logo_';
            sub_filter '/site.webmanifest' '/$app/site.webmanifest';
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
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
