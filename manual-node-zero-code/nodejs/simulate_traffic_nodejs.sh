#!/bin/bash

# ==============================================================================
# CONFIGURATION
# ==============================================================================
NAMESPACE="lab-apps"
DEPLOYMENT_NAME="manual-node-app"
LOCAL_PORT=8888
CONTAINER_PORT=8080
# ==============================================================================

echo "🚀 Starting Traffic Simulator for Manual Node.js App..."
echo "Target: $DEPLOYMENT_NAME in namespace: $NAMESPACE"

# --- CLEANUP FUNCTION ---
cleanup() {
    echo -e "\n🛑 Stopping traffic and closing port-forward..."
    # Kill the background port-forward process
    kill $(jobs -p) 2>/dev/null
    exit
}
trap cleanup SIGINT SIGTERM

# --- START PORT-FORWARD ---
echo "🔗 Opening tunnel to AKS (Local $LOCAL_PORT -> Container $CONTAINER_PORT)..."
kubectl port-forward deployment/$DEPLOYMENT_NAME -n $NAMESPACE $LOCAL_PORT:$CONTAINER_PORT > /dev/null 2>&1 &

# Wait for the tunnel to establish
sleep 3

# Check if port-forward is actually running
if ! ps -p $! > /dev/null; then
   echo "❌ Error: Failed to start port-forward. Check if the deployment exists."
   exit 1
fi

# --- TRAFFIC LOOP ---
echo "📈 Generating traces... (Press Ctrl+C to stop)"
COUNT=0

while true; do
    COUNT=$((COUNT+1))
    
    # Send request and capture HTTP status code
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$LOCAL_PORT/)
    
    if [ "$RESPONSE" == "200" ]; then
        echo "[$COUNT] ✅ Request Successful (HTTP 200) - Trace sent to Splunk"
    else
        echo "[$COUNT] ❌ Request Failed (HTTP $RESPONSE)"
    fi
    
    # Wait 2 seconds between requests
    sleep 2
done
