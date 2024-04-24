{ rustPlatform, lib, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "hyprland-workspaces";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "FieldofClay";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-4QGLTimIpx74gWUyHCheUZZT1WgVzBoJRY8OlUDdOh4=";
  };

  cargoSha256 = "sha256-9ndP0nyRBCdOGth4UWA263IvjbgnVW2x9PK8oTaMrxg=";

  meta = with lib; {
    description = "A multi-monitor aware Hyprland workspace widget";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
