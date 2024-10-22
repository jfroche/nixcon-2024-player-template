{
  description = "NixCon 2024 - NixOS on garnix: Production-grade hosting as a game";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.garnix-lib = {
    url = "github:garnix-io/garnix-lib";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };
  inputs.poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  outputs =
    {
      self,
      nixpkgs,
      garnix-lib,
      poetry2nix,
      ...
    }:
    let
      system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; config = { }; overlays = [ ]; };
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
    in {

      packages.x86_64-linux.app = mkPoetryApplication { projectDir = ./.; };
      packages.x86_64-linux.default = self.packages.x86_64-linux.app;

      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          garnix-lib.nixosModules.garnix
          ./module.nix
          {
            playerConfig = {
              webserver = self.packages.x86_64-linux.app;
              sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIo+ulCUfJjnCVgfM4946Ih5Nm8DeZZiayYeABHGPEl7";
              githubLogin = "jfroche";
              githubRepo = "nixcon-2024-player-template";
            };

            services.hoogle = {
              enable = true;
              port = 8081;
            };
            services.nginx.virtualHosts.default.locations."/hoogle".proxyPass = "http://127.0.0.1:8081";
          }
        ];
      };

      # Remove before starting the workshop - this is just for development
      checks = import ./checks.nix { inherit nixpkgs self; };

      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.poetry
        ];
        inputsFrom = [ self.packages.x86_64-linux.app ];

        shellHook = ''
          poetry lock
          #poetry shell
        '';
      };
    };
}
