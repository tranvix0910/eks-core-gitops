# EKS Workshop examples

These files support the guides. Creating a file does not deploy it.

| File | Purpose | Usage |
|---|---|---|
| `build-images.sh` | Build and push all seven images | Lives in [eks-core-apps](https://github.com/tranvix0910/eks-core-apps) as `scripts/build-images.sh` |
| `prepare-applications.sh` | Render Applications for your repository, account, and tag | Writes only `.workshop/applications`; review and apply in dependency order |
| `workload-values.yaml` | EFS, mixed-pool selectors, replicas, and PDBs for backend services | Added to valueFiles by the rendered Applications |
| `discovery-values.yaml` | Keep Eureka as a singleton | Override after common values |
| `proof/` | ArgoCD-managed EFS, spread, PDB, and log marker checks | The `workshop-proof` Application |
| `spot-proof.yaml` | Test the Spot pool | Apply during its exercise, verify, then delete |
| `arm64-proof.yaml` | Test ARM64 capacity | Check image platforms first |
| `ratio-proof.yaml` | Exercise mixed capacity | Run only under the ratio lab's stated conditions |
| `alloy-values.yaml` | Collect logs from every node through node-local API discovery | Install with Helm after configuring CA/TLS |

Start with the [learning path](https://tranvix0910.github.io/eks-core-docs/docs/platform-overview-and-deployment). The build script pushes images to ECR; the preparation script neither pushes Git changes nor applies resources. Apply YAML files at their documented steps because each has a distinct purpose and timing.
