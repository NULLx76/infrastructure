# This file was generated by pkgs.mastodon.updateScript.
{ fetchgit, applyPatches }: let
  src = fetchgit {
    url = "https://github.com/glitch-soc/mastodon.git";
    rev = "ed15893eed1d0f0b80867c0b834a5962c0dbd3c2";
    sha256 = "1lkcqqgk8pfrwjz5m8zq5dnwix18sc4i89cc58iqifwqzb53wqxl";
  };
in applyPatches {
  inherit src;
  patches = [];
}
