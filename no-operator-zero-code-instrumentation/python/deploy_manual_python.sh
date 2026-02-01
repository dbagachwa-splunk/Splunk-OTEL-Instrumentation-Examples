#!/bin/bash
APP_DIR="/Users/dbagachw/Documents/aks_lab/manual-node/python"
IMAGE_NAME="dbagachw391/python-otel:v1"
NAMESPACE="lab-apps"

cd "$APP_DIR"

echo "🏗️  Building Python image for linux/amd64..."
docker buildx build --platform linux/amd64 -t "$IMAGE_NAME" . --push

echo "🌐 Ensuring namespace exists..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "🛰️  Deploying to AKS..."
kubectl apply -f python-app.yaml -n "$NAMESPACE"
kubectl rollout restart deployment manual-python-app -n "$NAMESPACE"

echo "✅ Python Deployment Complete!"
