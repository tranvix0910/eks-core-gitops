# Three workshop capacity groups

| Group | NodePool | Workload label | Purpose |
|---|---|---|---|
| 1 | `batch-spot` | `workload=batch` | Spot only |
| 2 | `ms-od` + `ms-spot` | `workload=microservices` | Mixed capacity for backend services |
| 3 | `arm64` | `arch=arm64` | ARM64 validation |

Three logical groups are implemented as four NodePools. The infrastructure Managed Node Group is separate from these pools.

Install the controller and CRDs before EC2NodeClass, then apply NodePools. Follow the [configuration and workload tests](https://tranvix0910.github.io/eks-core-docs/docs/karpenter/ec2nodeclass-and-nodepools-configuration).

Weights of 100/10 and CPU limits of 24/72 provide a budget-based baseline and overflow arrangement; they do not enforce a fixed On-Demand:Spot node ratio of 1:3. See [measurement and the verification fixture](https://tranvix0910.github.io/eks-core-docs/docs/karpenter/on-demand-spot-ratio-and-limits).

Each Pod needs selectors and tolerations for its intended group. Keep the Karpenter controller on infrastructure nodes. Review drift and workload impact before changing pool requirements or AMIs.
