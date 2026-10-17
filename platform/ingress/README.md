# Admin ingress ownership

`admin-ingress.yaml` contains the manually applied lab Ingresses for ArgoCD,
Prometheus, Alertmanager, and JavaMelody. Grafana's Ingress belongs to Terraform.

## Kite

Kite's Helm release **and optional Ingress** belong to Terraform layer 20 in
`eks-core-terraform`. The canonical resource is
`20-cluster-workload/kite_ingress.tf`, address
`kubernetes_ingress_v1.kite[0]`. There is no Kite manifest to apply or sync from
this repository. Do not enable Helm's `ingress.enabled` or create another
ArgoCD Application for the same Ingress.

The former `kite-ingress.yaml` template has been removed to prevent competing
owners. Removing the template from Git does not remove an Ingress previously
applied by hand.

To retain an existing `kite-system/kite` Ingress, first enable
`kite_ingress_enabled` and configure `kite_admin_cidrs` in a gitignored
`kite.auto.tfvars` file. Inspect its current owner, then import it into layer
20's state before planning. If it is managed by another reconciler, migrate
ownership first; do not delete and recreate it. New installations create the
Ingress during Terraform apply after Kite is ready.

The Ingress joins the `eks-workload` admin ALB on HTTP port **8088**, forwarding
to Service `kite:8080`. Access is disabled by default and requires explicit IPv4
CIDRs when enabled. IP filtering does not encrypt HTTP traffic.

Follow [workshop step 2.5](https://tranvix0910.github.io/eks-core-docs/docs/platform-addons/kite-dashboard)
for environment setup, import, plan/apply, verification, CIDR updates, and
switching back to port-forward.
