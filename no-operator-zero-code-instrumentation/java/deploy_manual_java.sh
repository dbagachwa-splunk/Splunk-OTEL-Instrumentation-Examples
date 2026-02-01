#!/bin/bash
APP_DIR="/Users/dbagachw/Documents/aks_lab/manual-node/java"
IMAGE_NAME="dbagachw391/java-otel:v1"
NAMESPACE="lab-apps"

cd "$APP_DIR"

echo "🏗️  Building Java image for linux/amd64..."
docker buildx build --platform linux/amd64 -t "$IMAGE_NAME" . --push

echo "🛰️  Deploying to AKS..."
kubectl apply -f java-app.yaml -n "$NAMESPACE"
kubectl rollout restart deployment manual-java-app -n "$NAMESPACE"

echo "✅ Java Deployment Complete!"
