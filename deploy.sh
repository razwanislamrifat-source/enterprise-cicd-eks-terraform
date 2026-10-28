#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="advanced-cicd"
DEPLOYMENT="advanced-cicd-app"
TIMEOUT="300s"
ENVIRONMENT="${ENVIRONMENT:-dev}"
IMAGE_TAG="${IMAGE_TAG:-2.0.0}"

echo "Deploying to environment: ${ENVIRONMENT}"
echo "Using image tag: ${IMAGE_TAG}"

# Validate environment and image tag to prevent injection
if [[ ! "${ENVIRONMENT}" =~ ^(dev|prod)$ ]]; then
    echo "ERROR: Invalid ENVIRONMENT: ${ENVIRONMENT}. Must be dev or prod."
    exit 1
fi
if [[ ! "${IMAGE_TAG}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9\.]+)?$ ]]; then
    echo "ERROR: Invalid IMAGE_TAG: ${IMAGE_TAG}. Expected semantic version."
    exit 1
fi

# Determine overlay path
OVERLAY_PATH="k8s/overlays/${ENVIRONMENT}"
if [[ ! -d "${OVERLAY_PATH}" ]]; then
    echo "ERROR: Overlay directory ${OVERLAY_PATH} does not exist"
    echo "Available environments: dev, prod"
    exit 1
fi

# Update image tag in kustomization.yaml for the selected overlay
# Use kustomize edit to set the image tag without modifying the base
echo "Updating image tag in overlay..."
cd "${OVERLAY_PATH}"
kustomize edit set image advanced-cicd-app="advanced-cicd-app:${IMAGE_TAG}"
cd - > /dev/null

echo "Applying Kubernetes manifests using kustomize..."
kubectl apply -k "${OVERLAY_PATH}"

echo "Waiting for rollout to complete (timeout: ${TIMEOUT})..."
if ! kubectl rollout status deployment/${DEPLOYMENT} -n ${NAMESPACE} --timeout=${TIMEOUT}; then
    echo "ERROR: Rollout failed or timed out. Initiating rollback..."
    kubectl rollout undo deployment/${DEPLOYMENT} -n ${NAMESPACE} || true
    echo "Rollback triggered. Check pod status with: kubectl get pods -n ${NAMESPACE}"
    exit 1
fi

echo "Deployment completed successfully."
kubectl get pods -n ${NAMESPACE}