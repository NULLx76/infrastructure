# Kubernetes Cluster
This is my personal Kubernetes Cluster. [Flux] watches this git repo and reconciles and changes made to the cluster.

## Directory structure
The main directory is `cluster`, it contains the following subdirectories in the order that flux will apply them:
* **base**: the entrypoint for Flux
* **crds**: contains the CRDs that are needed for anything running in the cluster, these get applied earlier to make sure they exist
* **core**: important core infrastructure applications, grouped by namespace, that should never be pruned
* **apps**: common applications that are allowed to be pruned by flux

## References
Heavily inspired by: [onedr0p's cluster](https://github.com/onedr0p/home-cluster)

[Flux]: https://github.com/fluxcd/flux2
