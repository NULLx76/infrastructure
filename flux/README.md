# Kubernetes Cluster
This is my personal Kubernetes Cluster. [Flux] watches this git repo and reconciles and changes made to the cluster.

## Bootstrap
```sh
flux bootstrap git --url ssh://gitea@git.0x76.dev:42/v/infrastructure.git --branch=main --path=flux/olympus/base --ssh-key-algorithm=ed25519
```

## References
Heavily inspired by: [onedr0p's cluster](https://github.com/onedr0p/home-cluster)

[Flux]: https://github.com/fluxcd/flux2
