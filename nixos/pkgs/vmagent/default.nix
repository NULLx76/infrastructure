{ lib, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  pname = "vmagent";
  version = "1.59.0";

  src = fetchFromGitHub {
    owner = "VictoriaMetrics";
    repo = "VictoriaMetrics";
    rev = "v${version}";
    sha256 = "1mfdhv20m2xqsg37pdv4vbxdg8iri79grc4g4p9ph0js9yd6nbys";
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
