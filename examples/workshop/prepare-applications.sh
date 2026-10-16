#!/usr/bin/env bash
# Render Application resources locally. This script does not apply or push them.
set -euo pipefail
: "${AWS_ACCOUNT_ID:?Set AWS_ACCOUNT_ID}"
: "${AWS_REGION:?Set AWS_REGION}"
: "${IMAGE_TAG:?Set IMAGE_TAG}"
: "${WORKSHOP_REPO_URL:?Set WORKSHOP_REPO_URL}"
WORKSHOP_REVISION="${WORKSHOP_REVISION:-main}"
WORKSHOP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKSHOP_OUT="$WORKSHOP_ROOT/.workshop/applications"
mkdir -p "$WORKSHOP_OUT"
while read -r workshop_name workshop_config workshop_image; do
  workshop_patch=$(jq -n \
    --arg repo "$WORKSHOP_REPO_URL" --arg rev "$WORKSHOP_REVISION" \
    --arg image "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/shopnow/$workshop_image" \
    --arg tag "$IMAGE_TAG" --arg config "$workshop_config" \
    --arg name "$workshop_name" \
    '{spec:{source:{repoURL:$repo,targetRevision:$rev,helm:{
      valueFiles:(["values.yaml",("../"+$config+"/overlays/production/values.yaml"),
        "../../../examples/workshop/workload-values.yaml"] +
        (if $name == "shopnow-discovery-server" then ["../../../examples/workshop/discovery-values.yaml"] else [] end)),
      values: ("image:\n  repository: "+($image|tojson)+"\n  tag: "+($tag|tojson)+"\n")
    }}}}')
  kubectl patch --local --type=merge \
    -f "$WORKSHOP_ROOT/apps/shopnow-backend-config/$workshop_config/base/argocd.yaml" \
    -p "$workshop_patch" -o yaml > "$WORKSHOP_OUT/$workshop_name.yaml"
done <<'SERVICES'
shopnow-discovery-server shopnow-discovery-server-config shopnow-discovery-server
shopnow-config-server shopnow-config-server-config shopnow-config-server
shopnow-api-gateway shopnow-api-gateway-config shopnow-api-gateway
shopnow-product-service shopnow-product-service-config shopnow-product-service
shopnow-cart-service shopnow-cart-service-config shopnow-shopping-cart-service
shopnow-user-service shopnow-user-service-config shopnow-user-service
SERVICES
workshop_patch=$(jq -n --arg repo "$WORKSHOP_REPO_URL" --arg rev "$WORKSHOP_REVISION" \
  --arg image "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/shopnow/shopnow-frontend" \
  --arg tag "$IMAGE_TAG" \
  '{spec:{source:{repoURL:$repo,targetRevision:$rev,helm:{values:("image:\n  repository: "+($image|tojson)+"\n  tag: "+($tag|tojson)+"\n")}}}}')
kubectl patch --local --type=merge \
  -f "$WORKSHOP_ROOT/apps/shopnow-frontend-config/shopnow-frontend-config/base/argocd.yaml" \
  -p "$workshop_patch" -o yaml > "$WORKSHOP_OUT/shopnow-frontend.yaml"
workshop_patch=$(jq -n --arg repo "$WORKSHOP_REPO_URL" --arg rev "$WORKSHOP_REVISION" \
  '{spec:{source:{repoURL:$repo,targetRevision:$rev}}}')
kubectl patch --local --type=merge \
  -f "$WORKSHOP_ROOT/apps/shopnow-backend-config/shopnow-database-config/kustomize/argocd-application.yaml" \
  -p "$workshop_patch" -o yaml > "$WORKSHOP_OUT/shopnow-database-services.yaml"
jq -n --arg repo "$WORKSHOP_REPO_URL" --arg rev "$WORKSHOP_REVISION" \
  '{apiVersion:"argoproj.io/v1alpha1",kind:"Application",
    metadata:{name:"workshop-proof",namespace:"argocd"},
    spec:{project:"shopnow",source:{repoURL:$repo,targetRevision:$rev,path:"examples/workshop/proof"},
      destination:{server:"https://kubernetes.default.svc",namespace:"shopnow"},
      syncPolicy:{automated:{prune:true,selfHeal:true},syncOptions:["CreateNamespace=true"]}}}' \
  > "$WORKSHOP_OUT/workshop-proof.json"
printf 'Application files: %s\n' "$WORKSHOP_OUT"
