# This file was generated by pkgs.mastodon.updateScript.
{ fetchgit, applyPatches }: let
  src = fetchgit {
    url = "https://github.com/glitch-soc/mastodon.git";
    rev = "a1df9fdb06854bd55f018918236132ccfa7d9d84";
    sha256 = "0amqiigq3qgag6qm119aaysmd2k93vwgr1aynxjxmbpn35ykcay3";
  };
in applyPatches {
  inherit src;
  patches = [];
}
