# NixOS System Config Plans

## Levels of abstraction
1. Top-Level Host
  * This is a bare-metal or otherwise non-managed VM that itself will contain VMs and Containers
2. MicroVM / Container
  * As managed by a Top-Level Host
  * Contains Applications/Services
3. Services / Applications
  * Lowest Level, ran inside of a container or in special cases on a Top-Level Host
  * Often has a port and domain associated with it

## Open Questions
* Are MicroVMs and Containers LAN-routable or only on the Top-Level Host
  * Essentially Docker vs. Proxmox networking architecture


## Requirements
* DHCP should be able to autoconfigure IPs at least for Top-Level hosts
* DNS should be automatically generated from Service definitions
* A Reverse Proxy shoudl also be able to be automatically set-up from service definitions
* Wireguard should function correctly

