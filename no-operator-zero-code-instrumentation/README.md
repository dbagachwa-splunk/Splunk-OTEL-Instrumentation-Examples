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

### 1.2 Deployment Script (deploy_splunk_otel.sh)
Use this script to automate the deployment. It creates the necessary Kubernetes secrets and installs the collector via Helm.

## Step 2: Language Specific Examples

### Navigate to the folders below to see how to bake the OTel SDK into your container images:

* Node.js - Using npm install and NODE_OPTIONS.
* .NET - Using the CLR Profiler and Alpine/Musl support.
* Python - Using opentelemetry-instrument wrapper.
* Java - Using the -javaagent JVM argument.

## Step 3: Deploy Application using the deploy_manual_language.sh script

## Step 4: Run the simulate traffic script to generate traffic to capture traces

## Step 5: Validate K8s Infrastructure metrics and APM traces are showing up in Splunk Observability. Check for logs in Splunk Cloud/Enterprise
