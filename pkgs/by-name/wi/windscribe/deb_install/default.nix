{ pkgs ? import <nixpkgs> {} }:
let
  unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
  version = "2.9.9";
  debFile = pkgs.fetchurl {
    url = "https://github.com/Windscribe/Desktop-App/releases/download/v${version}/windscribe_${version}_amd64.deb";
    sha256 = "1ajv2284yjs55b29s93sivw4k5jygjq298c6p5sdagdn050jvin1";
  };
  qt6_5_1 = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/8e0510ff6acc4c185efad4fd0d30198a078c72b4.tar.gz") {};
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    qt6_5_1.qt6.qtbase
    qt6_5_1.qt6.wrapQtAppsHook
    qt6_5_1.qt6.qttools
    qt6_5_1.qt6.qtdeclarative

    autoPatchelfHook
    buildPackages.stdenv.cc
    gnutar

    libnl
    libcap_ng

    gdb
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${qt6_5_1.qt6.qtbase}/lib:$LD_LIBRARY_PATH

    mkdir -p windscribe_deb
    cd windscribe_deb/
    ar x ${debFile}
    tar xf data.tar.*
    cd opt/windscribe/
    autoPatchelf * **
    cd ../../etc/windscribe/
    autoPatchelf * **
    cd ../../opt/windscribe
    mv windscribectrld windscribectrld_old
    echo "#!/usr/bin/env bash\nsteam-run windscribectrld_old $@" >> windscribectrld
    chmod +x windscribectrld_old
  '';
}

# https://github.com/Windscribe/Desktop-App/releases/download/v2.9.9/windscribe_2.9.9_amd64.deb
