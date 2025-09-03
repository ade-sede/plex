{
  config,
  pkgs,
  ...
}: {
  users.users.ade-sede = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialPassword = "changeme";
    home = "/home/ade-sede";
    createHome = true;
  };

  users.users.pancho = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialPassword = "changeme";
    home = "/home/pancho";
    createHome = true;
  };

  users.users.plex = {
    isSystemUser = true;
    group = "plex";
    home = "/home/plex";
    createHome = true;
  };

  users.groups.plex = {};

  security.sudo.wheelNeedsPassword = false;
}
