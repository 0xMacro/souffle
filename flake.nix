{
  description = "Souffle Datalog Engine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24f0d4acd634792badd6470134c387a3b039dace";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = self.packages.${system}.souffle;
          souffle = pkgs.callPackage ./nix-souffle/default.nix { };
        };

        # Development shell with all dependencies
        devShells.default = pkgs.callPackage ./nix-souffle/shell.nix { };
      }
    ) // {
      # NixOS module for system-wide installation
      nixosModules.default = import ./nix-souffle/nixos-module.nix;
    };
}