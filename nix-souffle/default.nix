{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation rec {
  pname = "souffle";
  version = "2.4.1";  # Using stable release version 

  src = ./..;  # Use local directory (which is checked out to 2.4.1)

  nativeBuildInputs = [
    cmake
    pkg-config
    bison
    flex
    mcpp
    python3
    makeWrapper
  ];

  buildInputs = [
    libffi
    zlib
    sqlite
    ncurses
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
  ];

  cmakeFlags = [
    "-DSOUFFLE_USE_SQLITE=ON"
    "-DSOUFFLE_USE_ZLIB=ON"
    "-DSOUFFLE_USE_OPENMP=OFF" # Disable OpenMP to simplify threading requirements
    "-DSOUFFLE_USE_LIBFFI=ON"
    "-DSOUFFLE_DOMAIN_64BIT=ON" # Enable 64-bit word size
    "-DSOUFFLE_GIT=OFF" # Don't use git for version detection
    "-DBUILD_TESTING=OFF" # Skip tests for faster builds
    "-DPACKAGE_VERSION=${version}" # Set version explicitly
    # Linux-specific fixes
    "-DCMAKE_EXE_LINKER_FLAGS=${lib.optionalString (!stdenv.isDarwin) "-lpthread"}"
  ];
  
  # Fix finding pthreads on Darwin systems
  env.NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-framework CoreServices";

  # Specify the version explicitly to avoid needing git
  preConfigure = ''
    echo "${version}" > .version
  '';
  
  # Patch CMakeLists.txt to work on Nix
  postPatch = ''
    # Remove threading requirements for simplified build
    substituteInPlace CMakeLists.txt \
      --replace "find_package(Threads REQUIRED)" "# Threads handled manually"
    
    # Fix linker issues - disable lld (not available in Nix)
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_EXE_LINKER_FLAGS" "# set(CMAKE_EXE_LINKER_FLAGS"
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_MODULE_LINKER_FLAGS" "# set(CMAKE_MODULE_LINKER_FLAGS"
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_SHARED_LINKER_FLAGS" "# set(CMAKE_SHARED_LINKER_FLAGS"
    
    # Fix Apple Silicon linker issues if needed
    substituteInPlace src/CMakeLists.txt \
      --replace "-ld_classic" ""
  '';

  # Make binaries available to souffle when running
  # postInstall = ''
  #   wrapProgram $out/bin/souffle \
  #     --prefix PATH : ${lib.makeBinPath [ pkgs.mcpp ]}
  #   # Also wrap souffleprof if it needs the preprocessor too
  #   wrapProgram $out/bin/souffleprof \
  #     --prefix PATH : ${lib.makeBinPath [ pkgs.mcpp ]}
  
  # Set specific targets instead of building 'all'
  makeFlags = [ "-C" "src" "souffle" "souffleprof" ];

  meta = with lib; {
    description = "A translator of declarative Datalog programs into optimized C++ code";
    homepage = "https://souffle-lang.github.io";
    license = licenses.upl10 or {
      shortName = "UPL-1.0";
      fullName = "Universal Permissive License v1.0";
      url = "https://oss.oracle.com/licenses/upl/";
      free = true;
      redistributable = true;
    };
    platforms = platforms.unix;
    maintainers = [];
  };
}