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

  security.sudo.wheelNeedsPassword = false;
}
