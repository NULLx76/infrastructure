# 0x76's Infrastructure [![NixOS](https://github.com/NULLx76/infrastructure/actions/workflows/nixos.yml/badge.svg)](https://github.com/NULLx76/infrastructure/actions/workflows/nixos.yml)
This repository contains my IaC and GitOps code.

## Directory Structure
`flake.nix` is a NixOS flake which is the entrypoint for my NixOS config, it also contains a 'DevShell' containing all the tools needed
to deploy the infrastructure, this can be accessed running `nix develop`.
* **flux**: Kubernetes manifests as managed by [Flux]
* **nixos**: Nix configurations for my NixOS LXCs and VMs, deployed using [colmena].
* **terraform**: Terraform config for deploying said VMs and Containers onto Proxmox, using [terraform-provider-proxmox]


[Flux]: https://github.com/fluxcd/flux2
[deploy-rs]: https://colmena.cli.rs/unstable/
[terraform-provider-proxmox]: https://github.com/Telmate/terraform-provider-proxmox
