#!/bin/bash

# ==============================================================================
# CONFIGURATION
# ==============================================================================
NAMESPACE="lab-apps"
# ==============================================================================

echo "🚀 Starting deployment of Splunk Operator-instrumented apps..."

# 1. Create Namespace if it doesn't exist
echo "🌐 Ensuring namespace '$NAMESPACE' exists..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# 2. Deploy the Applications
# We use a Heredoc to keep the script self-contained
echo "🛰️  Applying application manifests..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-app
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: java-app
  template:
    metadata:
      labels:
        app: java-app
      annotations:
        instrumentation.opentelemetry.io/inject-java: "default/splunk-otel-collector"
    spec:
      containers:
      - name: java-app
        image: mcr.microsoft.com/openjdk/jdk:21-mariner
        command: ["jwebserver"]
        args: ["-b", "0.0.0.0", "-p", "8080"]
        ports:
        - containerPort: 8080
        env:
        - name: OTEL_SERVICE_NAME
          value: "java-app-dba"
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "deployment.environment=azure-dba-dev"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
      annotations:
        instrumentation.opentelemetry.io/inject-python: "default/splunk-otel-collector"
    spec:
      containers:
      - name: python-app
        image: tiangolo/uvicorn-gunicorn-fastapi:python3.9-slim
        ports:
        - containerPort: 80
        env:
        - name: OTEL_SERVICE_NAME
          value: "python-app-dba"
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "deployment.environment=azure-dba-dev"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dotnet-app
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dotnet-app
  template:
    metadata:
      labels:
        app: dotnet-app
      annotations:
        instrumentation.opentelemetry.io/inject-dotnet: "default/splunk-otel-collector"
        instrumentation.opentelemetry.io/otel-dotnet-auto-runtime: "linux-musl-x64"
    spec:
      containers:
      - name: dotnet-app
        image: mcr.microsoft.com/dotnet/samples:aspnetapp
        ports:
        - containerPort: 8080
        env:
        - name: OTEL_SERVICE_NAME
          value: "dotnet-app-dba"
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "deployment.environment=azure-dba-dev"
        - name: OTEL_DOTNET_AUTO_TRACES_INSTRUMENTATION_ENABLED
          value: "true"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
      annotations:
        instrumentation.opentelemetry.io/inject-nodejs: "default/splunk-otel-collector"
    spec:
      containers:
      - name: nodejs-app
        image: node:18-slim
        command: ["node"]
        args: ["-e", "const http = require('http'); http.createServer((req, res) => { res.writeHead(200); res.end('Hello'); }).listen(8080);"]
        env:
        - name: OTEL_SERVICE_NAME
          value: "nodejs-app-dba"
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "deployment.environment=azure-dba-dev"
EOF

# 3. Force a restart to ensure Operator triggers injection
echo "♻️  Restarting deployments to trigger Splunk OTel injection..."
kubectl rollout restart deployment java-app -n $NAMESPACE
kubectl rollout restart deployment python-app -n $NAMESPACE
kubectl rollout restart deployment dotnet-app -n $NAMESPACE
kubectl rollout restart deployment nodejs-app -n $NAMESPACE

# 4. Verification
echo "⏳ Waiting for pods to initialize..."
sleep 10
kubectl get pods -n $NAMESPACE

echo "------------------------------------------------------------"
echo "✅ Deployment Complete!"
echo "The Splunk OTel Operator will now inject the SDKs into these pods."
echo "Check for 'Init Containers' using: kubectl describe pod -n $NAMESPACE"
echo "------------------------------------------------------------"
