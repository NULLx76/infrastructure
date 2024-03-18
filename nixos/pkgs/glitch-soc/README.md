# Mastodon Glitch Edition

<https://github.com/glitch-soc/mastodon>

Mostly copied from [nixpkgs upstream](https://github.com/NixOS/nixpkgs/tree/master/pkgs/servers/mastodon).

Modifications for the new yarn berry lockfiles in `default.nix`, `yarn.nix` and `yarn-typescript.patch` stolen (with permissions) from [catgirl.cloud](https://git.catgirl.cloud/999eagle/dotfiles-nix/-/tree/main/overlay/mastodon/glitch).

See also: https://github.com/NixOS/nixpkgs/issues/277697

Update:

```
./update.sh --owner glitch-soc --repo mastodon --patches "./yarn-typescript.patch" --rev $COMMIT
```

The yarn hash isn't updated automatically due to the lockfile thing, run a build and copy the hash from the error message to source.nix by hand.
