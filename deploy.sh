#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="advanced-cicd"
DEPLOYMENT="advanced-cicd-app"
TIMEOUT="300s"
IMAGE_TAG="${IMAGE_TAG:-2.0.0}"

echo "Using image tag: ${IMAGE_TAG}"

# Substitute dynamic image tag using envsubst (preferred) or sed fallback
export IMAGE_TAG
if command -v envsubst >/dev/null 2>&1; then
    envsubst < k8s/deployment.yaml > /tmp/deployment-substituted.yaml
    cp /tmp/deployment-substituted.yaml k8s/deployment.yaml
else
    sed -i "s/\${IMAGE_TAG}/${IMAGE_TAG}/g" k8s/deployment.yaml
fi

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

echo "Waiting for rollout to complete (timeout: ${TIMEOUT})..."
if ! kubectl rollout status deployment/${DEPLOYMENT} -n ${NAMESPACE} --timeout=${TIMEOUT}; then
    echo "ERROR: Rollout failed or timed out. Initiating rollback..."
    kubectl rollout undo deployment/${DEPLOYMENT} -n ${NAMESPACE} || true
    echo "Rollback triggered. Check pod status with: kubectl get pods -n ${NAMESPACE}"
    exit 1
fi

echo "Deployment completed successfully."
kubectl get pods -n ${NAMESPACE}
