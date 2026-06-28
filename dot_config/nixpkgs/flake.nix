{
  description = "My system configuration";
  inputs = {
    # monorepo w/ recipes ("derivations")
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # system-level software and settings (macOS)
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    darwin,
    nixpkgs,
    ...
  } @ inputs: let
    # TODO: replace with your username
    primaryUser = "bryan";
  in {
    # build darwin flake using:
    # $ darwin-rebuild build --flake .#mac16
    darwinConfigurations."mac16" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [
        ./darwin
        ./hosts/mac16
      ];
      specialArgs = {inherit inputs self primaryUser;};
    };
  };
}
