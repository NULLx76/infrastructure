{ lib, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  pname = "vmagent";
  version = "1.79.0";

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "VictoriaMetrics";
    rev = "v${version}";
    sha256 = "sha256-+LirbGbKeazXMtgVh5kZP+KEk/fDbSxceZ26OlE0hbY=";
  };

  vendorSha256 = null;

  subPackages = [ "app/vmagent" ];

  meta = with lib; {
    description = "VictoriaMetrics metrics scraper";
    homepage = "https://github.com/VictoriaMetrics/VictoriaMetrics/tree/master/app/vmagent";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
