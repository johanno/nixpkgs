{ lib
, buildGoModule
, fetchFromGitHub
, nixosTests
}:

buildGoModule rec {
  pname = "artifactory_exporter";
  version = "1.13.1";
  rev = "v${version}";

  src = fetchFromGitHub {
    owner = "peimanja";
    repo = pname;
    rev = rev;
    hash = "sha256-TXLIuTY5COHlhyp8xL9X02DbK2ku9AKnW5a4FYdzMic=";
  };

  vendorHash = "sha256-Gin134G4NPK8M2E2RrgH62ieiuCw15jwm9SJg03w9ts=";

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${version}"
    "-X github.com/prometheus/common/version.Revision=${rev}"
    "-X github.com/prometheus/common/version.Branch=master"
    "-X github.com/prometheus/common/version.BuildDate=19700101-00:00:00"
  ];

  passthru.tests = { inherit (nixosTests.prometheus-exporters) artifactory; };

  meta = with lib; {
    description = "JFrog Artifactory Prometheus Exporter";
    homepage = "https://github.com/peimanja/artifactory_exporter";
    changelog = "https://github.com/peimanja/artifactory_exporter/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ lbpdt ];
  };
}
