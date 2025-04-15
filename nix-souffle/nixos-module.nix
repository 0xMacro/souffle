{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.souffle;
in {
  options.services.souffle = {
    enable = mkEnableOption "Souffle Datalog engine";
    
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./default.nix {};
      defaultText = "pkgs.souffle";
      description = "The Souffle package to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}