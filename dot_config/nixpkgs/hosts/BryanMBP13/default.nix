{
  lib,
  pkgs,
  ...
}: {
  services = {
    adguardhome.enable = false;
    nebula = {
      enable = false;
      DNSNode = true;
      caFile = "/Users/bryan/.config/nixpkgs/configs/ca.crt";
      crtFile = "/Users/bryan/.config/nixpkgs/hosts/BryanMBP13/node.crt";
      keyFile = "/Users/bryan/.config/nixpkgs/hosts/BryanMBP13/node.key";
    };
    rclone = {
      enable = false;
      remotes = {
        gdrive = {mountDir = "${builtins.getEnv "HOME"}/mnt/gdrive";};
        gbryan = {
          mountDir = "${builtins.getEnv "HOME"}/mnt/gbryan";
          flags = "--fast-list --allow-other --allow-non-empty --cache-db-purge --buffer-size 64M --use-mmap --dir-cache-time 72h --drive-chunk-size 64M --timeout 10m --vfs-cache-mode minimal --vfs-read-chunk-size 64M --vfs-read-chunk-size-limit 2048M --poll-interval 5m --transfers 16 --checkers 8 --syslog -v --drive-shared-with-me";
        };
      };
    };
    # duplicacy = {
    #  enable = false;
    #   threads = 12;
    #   b2_key = "K0001f0k74vZCWHzRPejTZqn4A0hdj4";
    #   b2_id = "000edae17924e7a0000000017";
    #   b2_password = ''U9Xm^Pm%2&dW6A'';
    #   gcd_password = ''54m*P6Szb4M&oc'';
    # };
    grafana = {
      enable = true;
      dataDir = "/Users/bryan/.local/share/grafana";
      configFile = "/Users/bryan/.config/grafana/grafana.ini";
    };
    xray = {
      enable = false;
      configFile = builtins.toPath ../configs/xray/config.json;
    };
    beancount = {
      enable = false;
      configFile = "/Users/bryan/Sync/Misc/beancount/main.bean";
    };
  };
  environment.systemPackages = with pkgs; [iperf];
  home-manager.users.bryan = {
    programs = {
      git = {
        userName = "Bryan Tu";
        userEmail = "bryantu824@gmail.com";
        signing = {
          key = "36146388B939FEAB";
          signByDefault = true;
        };
      };
    };
  };
}
