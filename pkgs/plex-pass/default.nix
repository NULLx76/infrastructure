{ plex, plexRaw-plexpass }:
# Copied from: https://github.com/tadfisher/flake/blob/ed949a619236ba30f0be614fed804abdf1e8005b/pkgs/plex-plexpass/default.nix
plex.override { plexRaw = plexRaw-plexpass; }
