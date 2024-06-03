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
in
pkgs.mkShell {
  buildInputs =with pkgs; [
      (python3.withPackages (pypkgs: with pypkgs; [
        colorama
        pyyaml
        requests
      ]))
      git
      gtest
      cmocka

      rapidjson
      nlohmann_json
      fmt
      spdlog

      qt6.full
      qt6.qtbase
      qt6.wrapQtAppsHook

      autoPatchelfHook
      wrapGAppsHook

      makeWrapper
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

      lzo
      lz4

      unstable.stdenv.cc.cc.lib
      libgcc
      c-ares
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

    shellHook = ''
      export VCPKG_ROOT=${unstable.vcpkg}/share/vcpkg
      export VCPKG_FORCE_SYSTEM_BINARIES=true
      export LD_LIBRARY_PATH=${unstable.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
      mkdir -p build-libs/ctrld
      ln -sf ${ctrld}/bin/ctrld build-libs/ctrld/ctrld
      mkdir -p build-libs/qt
      ln -sf ${pkgs.qt6.full}/* build-libs/qt/
      cd tools/deps
      #####./install_qt
      #./install_wireguard
      #./install_wstunnel
      cd ../
      # TOOD ABS path for .vcpkg from substitute (repo tools folder tools/.vcpkg)
      export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/home/johannes/gitstuff/windscribe-Desktop-App/tools/.vcpkg/installed/x64-linux

    '';
    # bash build_all

#     postPatch = ''
#       substituteInPlace tools/build_all.py \
#         --replace "--x-install-root={VCPKG_ROOT}/installed" "--x-install-root=.vcpkg/installed"
#     '';

}

