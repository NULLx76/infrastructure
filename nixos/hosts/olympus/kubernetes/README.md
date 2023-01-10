# Kubernetes NixOS LXC Container

## Required proxmox config
```ini
lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: a
lxc.cap.drop: 
lxc.mount.auto: proc:rw sys:rw
```
