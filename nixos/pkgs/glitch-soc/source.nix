# This file was generated by pkgs.mastodon.updateScript.
{ fetchgit, applyPatches }: let
  src = fetchgit {
    url = "https://git.0x76.dev/v/mastodon.git";
    rev = "54101563bbadbfafd9291a867d7fbea6df3a8b7b";
    sha256 = "1yi0jczfrsrj2rgzyawcpnm4sndyinpqrdaqbv6rz3maa5a0y6qb";
  };
in applyPatches {
  inherit src;
  patches = [];
}
