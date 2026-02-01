#!/bin/bash
#Use this script to automate the deployment. It creates the necessary Kubernetes secrets and installs the collector via Helm.
# --- CONFIGURATION ---
O11Y_TOKEN="<YOUR_O11Y_ACCESS_TOKEN>"
HEC_TOKEN="<YOUR_HEC_TOKEN>"
REALM="us1"
CLUSTER_NAME="otel-test-cluster"
ENVIRONMENT="azure-dba-dev"
USE_OPERATOR="true" #set to true if you want to use operator

VALUES_FILE="./splunk-values.yaml"
HEC_ENDPOINT="https://<YOUR_HEC_URL>/services/collector/event"
HEC_INDEX="<YOUR_INDEX>"

echo "🚀 Deploying Splunk OTel Collector..."

# Create Secret for Tokens
kubectl create secret generic splunk-tokens \
  --from-literal=o11y_TOKEN=$O11Y_TOKEN \
  --from-literal=HEC_TOKEN=$HEC_TOKEN \
  --dry-run=client -o yaml | kubectl apply -f -

# Add Helm Repo
helm repo add splunk-otel-collector-chart https://signalfx.github.io/splunk-otel-collector-chart --force-update
helm repo update

# Install/Upgrade
helm upgrade --install splunk-otel-collector splunk-otel-collector-chart/splunk-otel-collector \
  --values $VALUES_FILE \
  --set splunkObservability.accessToken=$O11Y_TOKEN \
  --set splunkPlatform.token=$HEC_TOKEN \
  --set clusterName=$CLUSTER_NAME \
  --set environment=$ENVIRONMENT \
  --set splunkObservability.realm=$REALM \
  --set splunkPlatform.endpoint=$HEC_ENDPOINT \
  --set splunkPlatform.index=$HEC_INDEX \
  --set operator.enabled=$USE_OPERATOR \
  --set operatorcrds.install=$USE_OPERATOR
