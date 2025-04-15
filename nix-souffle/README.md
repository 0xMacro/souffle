# Souffle Nix Package

This directory contains Nix package definitions for the [Souffle Datalog engine](https://souffle-lang.github.io/).

## Building on NixOS/macOS with Nix

### Using Nix Flakes (recommended)

```bash
# From the root of the Souffle repository
nix build   # Build Souffle version 2.4.1 from the local directory
```

### Using Legacy Nix Commands

```bash
# From the root of the Souffle repository
nix-build nix-souffle/default.nix   # Build Souffle version 2.4.1 from the local directory
```

Both methods create a result directory that symlinks to the built package.

## Development Shell

For development, you can use the provided shell configuration:

### Using Nix Flakes (recommended)

```bash
# From the root of the Souffle repository
nix develop
```

### Using Legacy Nix Commands

```bash
# From the root of the Souffle repository
nix-shell nix-souffle/shell.nix
```

This will drop you into a shell with all the necessary dependencies to build Souffle.
Inside the shell, you can build Souffle with:

```bash
mkdir -p build
cd build
cmake ..
make -j$(nproc)
```

## Using Souffle in Your NixOS Flake

Add Souffle to your flake.nix:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Add Souffle as an input
    souffle.url = "github:souffle-lang/souffle";
    # Or use a specific tag/revision
    # souffle.url = "github:souffle-lang/souffle/2.4.1-stable";
    
    # Tell Souffle to use the same nixpkgs
    souffle.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, souffle, ... }: {
    # Use as a NixOS module
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        souffle.nixosModules.default
        {
          services.souffle.enable = true;
          environment.systemPackages = [ souffle.packages.x86_64-linux.default ];
        }
      ];
    };
    
    # Or just include the package in your home-manager configuration
    homeConfigurations."your-username" = {
      home.packages = [ 
        souffle.packages.x86_64-linux.default
      ];
    };
  };
}
```

## NixOS Module (Legacy)

A module is provided that can be imported into your configuration.nix:

```nix
# In your configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    # Path to nixos-module.nix
    ./path/to/nix-souffle/nixos-module.nix
  ];

  services.souffle = {
    enable = true;
  };
}
```

## Build Options

The package is configured with the following features:
- SQLite support
- ZLIB support
- libffi support
- OpenMP disabled for better compatibility
- Tests disabled for faster builds

## Customization

You can customize the build by overriding attributes:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  souffle = pkgs.callPackage ./nix-souffle/default.nix {
    # Example customizations (not currently implemented but could be added):
    # enableOpenMP = true;
    # enableTests = true;
  };
in
souffle
```

## Dependencies

- CMake
- Bison
- Flex
- MCPP
- Python 3
- libffi
- zlib
- sqlite
- ncurses (macOS)
- CoreServices framework (macOS)

## License

Souffle is licensed under the Universal Permissive License (UPL), Version 1.0.