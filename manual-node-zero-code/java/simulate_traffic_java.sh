#!/bin/bash
NAMESPACE="lab-apps"
LOCAL_PORT=8085
CONTAINER_PORT=8080

cleanup() { kill $(jobs -p) 2>/dev/null; exit; }
trap cleanup SIGINT SIGTERM

echo "🔗 Opening tunnel to Java App..."
kubectl port-forward deployment/manual-java-app -n $NAMESPACE $LOCAL_PORT:$CONTAINER_PORT > /dev/null 2>&1 &

sleep 5
while true; do
    curl -s http://localhost:$LOCAL_PORT/ && echo " ✅ Java Trace Sent"
    sleep 2
done
