{
  config,
  pkgs,
  lib,
  mountPoint,
  ...
}: {
  services.bazarr = {
    enable = true;
    openFirewall = true;
    user = "root";
    group = "root";
    dataDir = "${mountPoint}/bazarr";
  };

  systemd.services.bazarr = {
    after = ["network.target" "juicefs-mount.service" "sonarr.service" "radarr.service"];
    requires = ["juicefs-mount.service" "sonarr.service" "radarr.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    preStart = lib.mkAfter ''
                  mkdir -p ${mountPoint}/bazarr

                  if [ -f ${mountPoint}/bazarr/config/config.ini ]; then
                    ${pkgs.gnused}/bin/sed -i 's|base_url = .*|base_url = /bazarr|' ${mountPoint}/bazarr/config/config.ini
                  else
                    mkdir -p ${mountPoint}/bazarr/config
                    cat > ${mountPoint}/bazarr/config/config.ini << 'EOF'
      [general]
      ip = 0.0.0.0
      port = 6767
      base_url = /bazarr
      path_mappings = []
      debug = False
      branch = master
      auto_update = True
      single_language = False
      minimum_score = 90
      use_scenename = True
      use_postprocessing = False
      postprocessing_cmd =
      use_sonarr = True
      use_radarr = True
      enabled_providers =
      login_required = False
      username =
      password =
      EOF
                  fi
    '';
  };
}
