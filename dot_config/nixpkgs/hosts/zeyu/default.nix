{
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) getEnv readFile fetchurl;
  homeDir = "/Users/zeyu";
in {
  services = {
    xray = {
      enable = true;
      configFile = "${homeDir}/.config/nixpkgs/hosts/ZeyuMacBookPro/xray/config.json";
      assetPath = "${homeDir}/.local/share/xray";
    };
    mysql = {
      enable = false;
      package = pkgs.mysql80;
      user = "zeyu";
      bind = "127.0.0.1";
      dataDir = "${homeDir}/Databases/mysql";
      extraOptions = ''
        key_buffer_size = 4G
        log-error = ${homeDir}/Library/Logs/mysql.err.log
      '';
    };
    # duplicacy = {
    # enable = false;
    # b2_key = "K000hO6iuDGz2/zcbEEKyWVhXm6Lg4Y";
    # b2_id = "000edae17924e7a0000000018";
    # b2_password = ''U9Xm^Pm%2&dW6A'';
    # gcd_password = ''nCa764s?\$a'';
    # };
  };
  environment.systemPackages = with pkgs; [
    # mypkgs.ImageOptim
  ];

  home-manager.users.zeyu = {
    programs = {
      git = {
        userName = "Irene Xia";
        userEmail = "xiazeyu27@gmail.com";
        signing = {
          key = "14E3BBC36251C614";
          signByDefault = true;
        };
        extraConfig = {github.user = "Irene Xia";};
      };
    };
  };
}
