{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    pkg-config
    bison
    flex
    mcpp
    python3
    libffi
    zlib
    sqlite
    ncurses
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.CoreServices
  ];

  shellHook = ''
    export PKG_CONFIG_PATH="${pkgs.libffi}/lib/pkgconfig:$PKG_CONFIG_PATH"
    export PATH="${pkgs.bison}/bin:$PATH"
    echo "Souffle development environment ready!"
    echo "Run 'mkdir -p build && cd build && cmake .. && make -j$(nproc)' to build"
  '';
}