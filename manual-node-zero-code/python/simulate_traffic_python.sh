#!/bin/bash
NAMESPACE="lab-apps"
LOCAL_PORT=5001
CONTAINER_PORT=5000

cleanup() { kill $(jobs -p) 2>/dev/null; exit; }
trap cleanup SIGINT SIGTERM

echo "🔗 Opening tunnel to Python App..."
kubectl port-forward deployment/manual-python-app -n $NAMESPACE $LOCAL_PORT:$CONTAINER_PORT > /dev/null 2>&1 &

sleep 5
while true; do
    curl -s http://localhost:$LOCAL_PORT/ && echo " ✅ Python Trace Sent"
    sleep 2
done
