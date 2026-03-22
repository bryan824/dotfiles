{
  config,
  lib,
  pkgs,
  primaryUser,
  ...
}: let
  inherit (builtins) getEnv readFile fetchurl;
in {
  services = {
    # rclone = {
    #   enable = false;
    #   remotes = {
    #     gcrypt = {mountDir = "${homeDir}/mnt/gptu";};
    #     selfhosted = {
    #       sourceDir = "selfhosted:/mnt/wd/Media";
    #       mountDir = "${homeDir}/mnt/selfhosted";
    #     };
    #     gbryan = {
    #       mountDir = "${homeDir}/mnt/gbryan";
    #       flags = "--fast-list --allow-other --allow-non-empty --cache-db-purge --buffer-size 64M --use-mmap --dir-cache-time 72h --drive-chunk-size 64M --timeout 10m --vfs-cache-mode minimal --vfs-read-chunk-size 64M --vfs-read-chunk-size-limit 2048M --poll-interval 5m --transfers 16 --checkers 8 --syslog -v --drive-shared-with-me";
    #     };
    #   };
    # };
    # rime.enable = false;
    # postgresql = {
    #   enable = true;
    #   dataDir = "/Users/bryan/Databases/postgresql";
    #   package = pkgs.postgresql_17;
    # };
  };
  environment.systemPackages = with pkgs; [
    terminal-notifier
    # efm-langserver
    # pyEnv
    # mypkgs.KeyCodes
    # mypkgs.ImageOptim
    # mypkgs.Proxyman
    # awscli2
    wrk
    # du-dust
    patchelf
    opencc
    direnv
    bandwhich
    diesel-cli
    bun
    sqlite
    argocd
    libpq
    # esbuild
    cmake
    # diskonaut
    imagemagick
    squashfsTools
    # wireshark
    jq
    xh
    btop
    # dotenv-linter
    ffmpeg
    # ghostscript
    # bettercap
    git-cliff
    # czkawka
    brotli
    shfmt
    shellcheck
    alejandra
    kubectl
    kubernetes-helm
    rsync
    httpstat
    tokei
    hexyl
    grex
    graphviz
    # lnav
    rage
    # gitui
    lazygit
    git-sizer
    chezmoi
    # lorri # improve `nix-shell` experience in combination with `direnv`
    # monolith
    # httpie
    watchexec
    jdk17_headless
    kcat
    minikube
    colima
    # cargo-make
    plantuml
    asciinema
    helix
    # commitizen
    just
    gitAndTools.delta
    docker
    talosctl
    dolt
    exif
    arping
    exiftool
    _7zz
    pre-commit
    nodePackages.pnpm
    bit
    protobuf
    kubectl
    go
    # selenium-server-standalone
    nmap
    # sass
    hyperfine # benchmarking tool
    mask
    usql
    watch
    neovim
    iperf
    yazi
    typst
    procs
    tealdeer # rust implementation of `tldr`
    xz # extract XZ archives
    # mypkgs.nix-stray-roots
    cloc # source code line counter
    gnuplot
    kustomize
    rustscan
    cachix
  ];
  # system.activationScripts.postActivation.text = ''
  #   ln -sf "${homeDir}/.config/nixpkgs/users/bryan/firefox/user.js" "${homeDir}/Library/Application Support/Firefox/Profiles/home/user.js"
  #   ln -sf "${homeDir}/.config/nixpkgs/configs/rustfmt" "${homeDir}/.config/rustfmt"
  #   # ln -sf "${homeDir}/.config/nixpkgs/users/bryan/firefox/chrome/" "${homeDir}/Library/Application Support/Firefox/Profiles/home/chrome/"
  # '';
  # home-manager.users.bryan = {
  #   programs = {
  #     git = {
  #       userName = "Bryan Tu";
  #       userEmail = "bryantu824@gmail.com";
  #       signing = {
  #         key = "36146388B939FEAB";
  #         signByDefault = true;
  #       };
  #       extraConfig = {github.user = "Bryan Tu";};
  #     };
  #   };
  # };
  networking.computerName = "Bryan@💻";
  networking.hostName = "BryanMacBookPro";
  nixpkgs.hostPlatform = "x86_64-darwin";
}
