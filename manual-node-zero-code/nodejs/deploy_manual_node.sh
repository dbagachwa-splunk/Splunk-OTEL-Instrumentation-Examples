#!/bin/bash

# ==============================================================================
# CONFIGURATION
# ==============================================================================
APP_DIR="/Users/dbagachw/Documents/aks_lab/manual-node/nodejs"
IMAGE_NAME="dbagachw391/nodejs-otel:v1"
NAMESPACE="lab-apps"
YAML_FILE="nodejs-app.yaml"
# ==============================================================================

echo "🚀 Starting Manual Node.js Deployment..."

# 1. Navigate to the application directory
cd "$APP_DIR" || { echo "❌ Directory not found: $APP_DIR"; exit 1; }

# 2. Build the Docker Image
# IMPORTANT: We use --platform linux/amd64 so the Mac-built image runs on Azure
echo "🏗️  Building Docker image for linux/amd64..."
docker buildx build --platform linux/amd64 -t "$IMAGE_NAME" . --load

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed!"
    exit 1
fi

# 3. Push to Docker Hub
echo "📤 Pushing image to Docker Hub..."
docker push "$IMAGE_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Docker push failed! Ensure you are logged in (docker login)."
    exit 1
fi

# 4. Prepare Kubernetes Namespace
echo "🌐 Ensuring namespace '$NAMESPACE' exists..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# 5. Deploy to AKS
echo "🛰️  Applying Kubernetes manifest: $YAML_FILE..."
kubectl apply -f "$YAML_FILE" -n "$NAMESPACE"

# 6. Force a restart to pull the latest image
echo "♻️  Restarting deployment to ensure fresh pull..."
kubectl rollout restart deployment manual-node-app -n "$NAMESPACE"

# 7. Verification
echo "⏳ Waiting for pod to initialize..."
sleep 5
kubectl get pods -n "$NAMESPACE" -l app=manual-node-app

echo "------------------------------------------------------------"
echo "✅ Deployment Complete!"
echo "To test traces, run:"
echo "kubectl port-forward deployment/manual-node-app -n $NAMESPACE 8888:8080"
echo "curl http://localhost:8888/"
echo "------------------------------------------------------------"
