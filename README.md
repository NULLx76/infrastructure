# 0x76's Infrastructure
This repository contains my IaC and GitOps code.

## Directory Structure
`flake.nix` is a NixOS flake which is the entrypoint for my NixOS config, it also contains a 'DevShell' containing all the tools needed
to deploy the infrastructure, this can be accessed running `nix develop`.
* **flux**: Kubernetes manifests as managed by [Flux]
* **nixos**: Nix configurations for my NixOS LXCs and VMs, deployed using [deploy-rs].
* **terraform**: Terraform config for deploying said VMs and Containers onto Proxmox, using [terraform-provider-proxmox]


[Flux]: https://github.com/fluxcd/flux2
[deploy-rs]: https://github.com/serokell/deploy-rs
[terraform-provider-proxmox]: https://github.com/Telmate/terraform-provider-proxmox
