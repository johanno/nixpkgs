{ pkgs ? import <nixpkgs> {} }:
let
  unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    qt6.qtbase
    qt6.wrapQtAppsHook
    autoPatchelfHook
    ar
  ];

 shellHook = ''
    ar x
  '';
}

# https://github.com/Windscribe/Desktop-App/releases/download/v2.9.9/windscribe_2.9.9_amd64.deb