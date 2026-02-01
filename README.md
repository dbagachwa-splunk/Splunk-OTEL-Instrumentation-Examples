# Splunk OpenTelemetry (OTel) Instrumentation Examples

This repository provides step-by-step examples and configuration files for instrumenting microservices with the Splunk Distribution of OpenTelemetry. 

## Use Case: Manual Instrumentation
These examples focus on **Manual Instrumentation (No Operator)**. This approach is ideal for environments where:
* Multiple Kubernetes Operators might conflict (e.g., coexisting with AppDynamics).
* Teams require full control over the SDK version and initialization logic.
* High-security environments where "magic" sidecar injection is restricted.

## Telemetry Routing Architecture
The configurations in this repo are set up for a **Hybrid Telemetry Path**:
1. **Metrics & Traces:** Sent to **Splunk Observability Cloud** for real-time APM and Infrastructure monitoring.
2. **Logs:** Sent to **Splunk Cloud/Enterprise** via the HTTP Event Collector (HEC) for long-term retention and log analysis.

---

## Step 1: Deploy the Splunk OTel Collector
Before instrumenting applications, the Collector must be running in your cluster to act as the telemetry gateway.

### Prerequisites
* A running Kubernetes cluster (AKS, EKS, GKE, etc.)
* Helm installed on your local machine.
* Splunk Observability Access Token and Realm.
* Splunk Cloud/Enterprise HEC Token and Endpoint.

### 1.1 Configuration (`splunk-values.yaml`)
Create a file named `splunk-values.yaml`. This file configures the collector to route data to both Splunk platforms.

```yaml
cloudProvider: azure
distribution: aks
clusterName: <YOUR_CLUSTER_NAME>
environment: <YOUR_ENV_NAME>

splunkObservability:
  realm: <YOUR_REALM>
  profilingEnabled: true

splunkPlatform:
  # Logs are routed here via HEC
  endpoint: "https://<YOUR_SPLUNK_HEC_URL>/services/collector/event"
  index: "<YOUR_LOG_INDEX>"
  source: "kubernetes"
  insecureSkipVerify: true

gateway:
  enabled: false

operator:
  # Set to true if you want to use the operator for other apps, 
  # but manual apps will ignore it.
  enabled: true

agent:
  discovery:
    enabled: true
