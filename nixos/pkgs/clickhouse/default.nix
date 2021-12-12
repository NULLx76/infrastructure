{ stdenv, dpkg, autoPatchelfHook, fetchurl, lib, glibc }:
stdenv.mkDerivation rec {
  pname = "clickhouse";
  version = "21.11.5.33";

  broken = stdenv.buildPlatform.is32bit;

  sourceRoot = ".";

  srcs = [
    (fetchurl {
      url =
        "https://github.com/ClickHouse/ClickHouse/releases/download/v${version}-stable/clickhouse-common-static-${version}.tgz";
      sha256 = "sha256-WYSxRQWj6We5v3trMZ0r9xr0kyApyEL444os7yTw8fI=";
    })
    (fetchurl {
      url =
        "https://github.com/ClickHouse/ClickHouse/releases/download/v${version}-stable/clickhouse-server-${version}.tgz";
      sha256 = "sha256-mxEObzTlW1A7p8END24H/ovxF/PsmmoPWvEjbRmS9X0=";
    })
  ];

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    glibc
  ];
  # hardeningDisable = [ "format" ];

  installPhase = ''
    mkdir -p $out/{bin,etc}
    cp -av clickhouse-server-${version}/usr/bin/* $out/bin/
    cp -av clickhouse-server-${version}/etc/clickhouse-server $out/etc/
    cp -av clickhouse-common-static-${version}/usr/bin/* $out/bin/

    runHook postInstall
  '';

  postInstall = ''
    sed -i -e '\!<log>/var/log/clickhouse-server/clickhouse-server\.log</log>!d' $out/etc/clickhouse-server/config.xml
    substituteInPlace $out/etc/clickhouse-server/config.xml --replace "<errorlog>/var/log/clickhouse-server/clickhouse-server.err.log</errorlog>" "<console>1</console>"
  '';

  meta = with lib; {
    homepage = "https://clickhouse.tech/";
    description = "Column-oriented database management system";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
