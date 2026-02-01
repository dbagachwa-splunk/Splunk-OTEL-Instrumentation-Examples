#!/bin/bash
NAMESPACE="lab-apps"
# Local ports on your Mac
JAVA_PORT=8085
PYTHON_PORT=8081
DOTNET_PORT=8083
NODEJS_PORT=8082

cleanup() {
    echo -e "\n🛑 Stopping traffic..."
    kill $(jobs -p) 2>/dev/null
    exit
}
trap cleanup SIGINT SIGTERM

echo "🔗 Opening port-forwards..."
# All apps now listen on their respective internal ports
kubectl port-forward deployment/java-app -n $NAMESPACE $JAVA_PORT:8080 > /dev/null 2>&1 &
kubectl port-forward deployment/python-app -n $NAMESPACE $PYTHON_PORT:80 > /dev/null 2>&1 &
kubectl port-forward deployment/dotnet-app -n $NAMESPACE $DOTNET_PORT:8080 > /dev/null 2>&1 &
kubectl port-forward deployment/nodejs-app -n $NAMESPACE $NODEJS_PORT:8080 > /dev/null 2>&1 &

sleep 5
echo "📈 Generating traffic for environment: azure-dba-dev..."

while true; do
    # All of these should now return "✅" because they are all HTTP
    curl -s http://localhost:$JAVA_PORT/ > /dev/null && echo "✅ Java" || echo "❌ Java Failed"
    curl -s http://localhost:$PYTHON_PORT/ > /dev/null && echo "✅ Python" || echo "❌ Python Failed"
    curl -s http://localhost:$DOTNET_PORT/ > /dev/null && echo "✅ .NET" || echo "❌ .NET Failed"
    curl -s http://localhost:$NODEJS_PORT/ > /dev/null && echo "✅ Node.js" || echo "❌ Node.js Failed"
    sleep 2
done
