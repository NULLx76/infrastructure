{ lib, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  pname = "vmagent";
  version = "1.80.0";

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "VictoriaMetrics";
    rev = "v${version}";
    sha256 = "sha256-SIwl8Mgbkk/z3xZ6wCmce7D2T2A2+dcuQ607BOsfrkQ=";
    # sha256 = lib.fakeSha256;
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
