{
  pkgs,
  inputs,
  self,
  lib,
  primaryUser,
  ...
}: let
  inherit (lib) optional optionalAttrs mkIf mkMerge mkDefault flatten;
  inherit (builtins) toPath readFile getEnv;
in {
  imports = [
    ./services.nix
    ./settings.nix
  ];

  networking = {
    knownNetworkServices = [
      "Thunderbolt Bridge"
      "USB 10/100/1000 LAN"
      "Wi-Fi"
    ];
    dns = [
      "10.24.0.1"
    ];
  };

  environment = {
    pathsToLink = ["/share/zsh" "/Applications" "/config"];
    # pathsToLink = ["/Applications"];
    systemPackages = with pkgs; [
      # mypkgs.AppCleaner
      # mypkgs.Kap
      coreutils
      ripgrep
      gnupg
      fd
      eza
      bat
      zoxide
      curl
      wget
      rclone
      openssl
      pkg-config
      gnused
      neovim
    ];
  };

  # Font
  # fonts = {
  #   packages = with pkgs; [
  #     source-sans-pro
  #     (nerdfonts.override {fonts = ["FantasqueSansMono"];})
  #   ];
  # };

  nix = {
    settings = {
      max-jobs = "auto";
      # The special value 0 means that the builder should use all available CPU cores in the system.
      build-cores = 0;
      substituters = [
        "https://cache.nixos.org/"
        "https://malo.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "malo.cachix.org-1:fJL4+lpyMs/1cdZ23nPQXArGj8AS7x9U67O8rMkkMIo="
      ];

      trusted-users = [
        "@admin"
      ];

      auto-optimise-store = false;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  system = {
    checks.verifyNixPath = false;
    stateVersion = 4;
    primaryUser = primaryUser;
  };
  users.users.${primaryUser} = {
    home = "/Users/${primaryUser}";
    shell = pkgs.zsh;
  };

  time.timeZone = "America/New_York";

  launchd.daemons = {
    limit-maxfiles = {
      command = "/bin/launchctl limit maxfiles 524288 524288";
      serviceConfig.RunAtLoad = true;
    };

    limit-maxproc = {
      command = "/bin/launchctl limit maxproc 2048 2048";
      serviceConfig.RunAtLoad = true;
    };
  };
}
