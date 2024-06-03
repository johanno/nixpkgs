{ pkgs ? import <nixpkgs> {} }:
let
  unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
  ctrld =  (pkgs.stdenv.mkDerivation {
      pname = "ctrld";
      version = "1.3.6";

      src = builtins.fetchTarball {
        url = "https://github.com/Control-D-Inc/ctrld/releases/download/v${ctrld.version}/ctrld_${ctrld.version}_linux_amd64.tar.gz";
        sha256 = "1c4lvfhzjp3fmb059g00x98lx6pai2z3rdb55aiw1zd1ianh4655";
      };

      phases = [ "installPhase" ];

#       unpackPhase = ''
#         tar -xzf $src
#       '';

      installPhase = ''
        mkdir -p $out/bin
        cp $src/ctrld_${ctrld.version}_linux_amd64/ctrld $out/bin/
      '';
  });
  windscribe = (pkgs.stdenv.mkDerivation {
    name = "windscribe-desktop";
    version = "2.10.10";

    src = pkgs.fetchFromGitHub {
      owner = "Windscribe";
      repo = "Desktop-App";
      rev = "v${windscribe.version}";
      sha256 = "A1JPEayJt44Jk88dwWrlnNDFTA9C5tWuziVbu7blAPQ=";
    };

    installPhasePrivileged = true;

    buildInputs =with pkgs; [
      (python3.withPackages (pypkgs: with pypkgs; [
        colorama
        pyyaml
        requests
      ]))
      git
      autoPatchelfHook
      wrapGAppsHook
      pkg-config
      unstable.cmake
      unstable.vcpkg
      unstable.ninja
      go
      gcc
      automake
      curl
      patchelf
      fakeroot
      zip
      unzip
      pkg-config
      wget
      autoconf
      libtool
      ctrld

      unstable.stdenv.cc.cc.lib
      c-ares
      libgcc
      libpam-wrapper
      libGL
      fontconfig
      libnl
      libcap_ng
      freetype
      xorg.libX11
  #     xorg.libX11_xcb
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrender
      xorg.libxcb
      xorg.xcbutil
  #     xorg.libxcb_glx
      xorg.xcbutilkeysyms
      xorg.xcbutilimage
      xorg.libxshmfence
  #     xorg.libxcb_icccm
  #     xorg.libxcb_sync
      xorg.libXfixes
  #     xorg.libxcb_shape
      xorg.libXrandr
      xorg.xcbutilrenderutil
      xorg.libXrender
      xorg.libXinerama
      xorg.xkbutils
  #     xorg.libxkbcommon
  #     xorg.libxkbcommon_x11
      wayland
    ];

    configurePhase = ''
      export VCPKG_ROOT=${unstable.vcpkg}/bin
      export VCPKG_FORCE_SYSTEM_BINARIES=true
      export HOME=/build/source
      export LD_LIBRARY_PATH=${unstable.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
    '';

    postPatch = ''
      substituteInPlace tools/build_all.py \
        --replace "--x-install-root={VCPKG_ROOT}/installed" "--x-install-root=.vcpkg/installed"
    '';

    buildPhase = ''
      mkdir -p build-libs/ctrld
      ln -sf ${ctrld}/bin/ctrld build-libs/ctrld/ctrld
    '';

    installPhase = ''
      cd tools
      bash build_all
    '';
  });
in
pkgs.mkShell {
  packages = with pkgs; [
    windscribe
  ];
}


