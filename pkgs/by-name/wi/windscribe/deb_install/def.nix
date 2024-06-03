{ pkgs ? import <nixpkgs> {} }:
let
  pname = "windscribe";
  version = "2.9.9";
  windscribeDeb = pkgs.fetchurl {
    url = "https://github.com/Windscribe/Desktop-App/releases/download/v${version}/windscribe_${version}_amd64.deb";
    sha256 = "1ajv2284yjs55b29s93sivw4k5jygjq298c6p5sdagdn050jvin1";
  };
  qt6_5_1 = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/8e0510ff6acc4c185efad4fd0d30198a078c72b4.tar.gz") {};
  windscribe-pkg = pkgs.stdenvNoCC.mkDerivation {
    name = "${pname}-pkg-${version}";
    srcs = [ windscribeDeb ];

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook

      qt6_5_1.qt6.qtbase
      qt6_5_1.qt6.wrapQtAppsHook
      qt6_5_1.qt6.qttools
      qt6_5_1.qt6.qtdeclarative

      qt6_5_1.wayland

      libnl
      libcap_ng
    ];

    unpackPhase = ''
      dpkg-deb --fsys-tarfile ${windscribeDeb} | tar -x --no-same-permissions --no-same-owner
    '';

    postPatch = ''
      substituteInPlace etc/systemd/system/windscribe-helper.service \
        --replace ExecStart={/opt/windscribe/helper,$out/opt/windscribe/helper}
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R opt usr  $out

      runHook postInstall
    '';

    postInstall = ''
      install -Dm444 etc/systemd/system/windscribe-helper.service -t $out/lib/systemd/system
    '';
  };
in
(pkgs.buildFHSEnv {
  inherit pname version;
  targetPkgs = pkgs: (with pkgs; [
    windscribe-pkg
#    steam-run

    gdb
  ]);

  runScript = pkgs.writeShellScript "windscribe-wrapper.sh" ''
    export LD_LIBRARY_PATH=${qt6_5_1.qt6.qtbase}/lib:$LD_LIBRARY_PATH
    cd ${windscribe-pkg}/opt/windscribe/
    bash
  '';
}).env

# https://github.com/Windscribe/Desktop-App/releases/download/v2.9.9/windscribe_2.9.9_amd64.deb
