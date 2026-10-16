# eks-core-gitops

Kubernetes manifests for the EKS Core platform, reconciled by ArgoCD.

```
platform/
  bootstrap/        app-of-apps and the ShopNow ArgoCD Applications
  addons/           eks-workload add-ons: ArgoCD, LBC, cert-manager, Karpenter, KEDA, Prometheus, Alloy, Rancher…
  nodepools/        Karpenter EC2NodeClass and NodePools
  ingress/          Shared admin ingress
  observability/    eks-observability: Mimir, Loki, Grafana, Prometheus, internal ALB and TLS
apps/
  shopnow-backend-config/    Helm charts and ArgoCD config for the backend services and databases
  shopnow-frontend-config/   Frontend chart (Argo Rollouts blue-green)
labs/
  custom-networking/         VPC CNI custom networking lab manifests
```

ArgoCD's `app-of-apps` points at `platform/` in this repository.

## Placeholders to fill before syncing

Account-specific values are not committed. Replace them in your fork (or with an overlay) before ArgoCD syncs:

| Placeholder | Where |
|---|---|
| `<AWS_ACCOUNT_ID>` | ECR image repositories, S3 bucket names in the Mimir/Loki values, ACM ARN |
| `<CERTIFICATE_ID>` | `platform/observability/ingress/internal-ingress.yaml` |
| `<SUBNET_ID>`, `<SECURITY_GROUP_ID>` | `labs/custom-networking/eni-configs.yaml` |

## Related repositories

| Repository | Contents |
|---|---|
| [eks-core-docs](https://github.com/tranvix0910/eks-core-docs) | Documentation — [published site](https://tranvix0910.github.io/eks-core-docs/) |
| [eks-core-terraform](https://github.com/tranvix0910/eks-core-terraform) | Network and EKS clusters |
| **eks-core-gitops** | This repository |
| [eks-core-apps](https://github.com/tranvix0910/eks-core-apps) | ShopNow service source code and image build script |

Bootstrap order: [GitOps bootstrap order](https://tranvix0910.github.io/eks-core-docs/docs/platform-addons/gitops-bootstrap-order).
