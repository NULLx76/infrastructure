# 0x76's Infrastructure
This repository contains my fleet of VMs, Containers and Bare Metal machines.

## Directory Structure
`flake.nix` is a NixOS flake which is the entrypoint for my NixOS config, it also contains a 'DevShell' containing all the tools needed
to deploy the infrastructure, this can be accessed running `nix develop`.
* **flux**: Kubernetes manifests as managed by [Flux]
* **nixos**: Nix configurations for my NixOS LXCs and VMs, deployed using [colmena].


[Flux]: https://github.com/fluxcd/flux2
[colmena]: https://colmena.cli.rs/unstable/

## Inspired by the following repos
* <https://github.com/colemickens/nixcfg>
* <https://github.com/serokell/pegasus-infra>
* <https://git.asraphiel.dev/j00lz/strato-infra>
* <https://github.com/tadfisher/flake>
