{ lib, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  pname = "weave-gitops";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "weaveworks";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-nXFR+X63yp9IFTeW41ncBt77bCD3QFTs4phJMMLWrxs=";
  };

  ldflags = [ "-s" "-w" "-X github.com/weaveworks/weave-gitops/cmd/gitops/version.Version=${version}" ];

  vendorSha256 = "sha256-3CgR9F3Bz4k1MVOufaF/E2GD6+bTOnnUqOXkNO9ZFrc=";

  subPackages = [ "cmd/gitops" ];

  meta = with lib; {
    homepage = "https://github.com/weaveworks/weave-gitops";
    description = "Weave Gitops CLI";
    license = licenses.mpl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ nullx76 ];
  };
}
