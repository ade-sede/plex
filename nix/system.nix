{
  config,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "UTC";

  nixpkgs.config.allowUnfree = true;

  boot.supportedFilesystems = ["fuse"];

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    sqlite
    juicefs
    fuse
    qbittorrent-nox
  ];

  system.stateVersion = "24.11";
}
