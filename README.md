# Splunk OpenTelemetry (OTel) Zero-Code Instrumentation (Operator)

This directory provides examples of how to leverage the **Splunk OTel Operator** to automatically instrument applications without modifying a single line of code or changing your Docker images.

## Use Case: Operator-Based Instrumentation
These examples focus on **Zero-Code Instrumentation**. This approach is ideal for environments where:
* Teams want to standardize instrumentation across hundreds of microservices instantly.
* Developers should not be responsible for managing OTel SDK versions or logic.
* Centralized management of telemetry configuration is required via Kubernetes annotations.

## Telemetry Routing Architecture
The configurations in this repo are set up for a **Hybrid Telemetry Path**:
1. **Metrics & Traces:** Sent to **Splunk Observability Cloud** for real-time APM and Infrastructure monitoring.
2. **Logs:** Sent to **Splunk Cloud/Enterprise** via the HTTP Event Collector (HEC).

---

## Step 1: Deploy the Splunk OTel Collector with Operator
The Splunk OTel Operator must be enabled during the collector deployment to listen for new pods and perform the "injection" of the OTel SDKs.

### 1.1 Configure the Deployment Script
Ensure the following variable is set to `true` in your `deploy_splunk_otel.sh` script (located in the root directory):

bash
USE_OPERATOR="true"
---

### 1.2 Execute Deployment

Run the script to install the collector and the Operator CRDs:

`./deploy_splunk_otel.sh`

## Step 2: Deploy Applications

The deploy_operator_apps.sh script will deploy standard, un-instrumented container images (Java, Python, .NET, and Node.js).

The script automatically adds the required Kubernetes Annotations to the deployments. These annotations act as a "signal" to the Splunk Operator to inject the appropriate SDK at runtime.

Example Annotation (.NET):

`
annotations:
  instrumentation.opentelemetry.io/inject-dotnet: "default/splunk-otel-collector"
  instrumentation.opentelemetry.io/otel-dotnet-auto-runtime: "linux-musl-x64"`

Run the Deployment Script:

`./deploy_operator_apps.sh`


## Step 3: Simulate Traffic

Once the pods are in a Running state, the Operator has already performed the "Magic" injection. Use the simulation script to generate HTTP traffic and trigger traces.

`./simulate_traffic.sh`


## Step 4: Validation

### 4.1 Verify Injection (CLI)

Pick any pod and verify that the Splunk Operator has added an Init Container and the necessary Environment Variables:

`kubectl describe pod -n lab-apps -l app=java-app`


Look for: Init Containers: opentelemetry-auto-instrumentation-java
Look for: JAVA_TOOL_OPTIONS: -javaagent:/otel-auto-instrumentation/javaagent.jar

### 4.2 Verify in Splunk Observability

Log in to Splunk Observability Cloud.
Navigate to APM -> Service Map.
Filter by Environment: azure-dba-dev.
Confirm that java-app-dba, python-app-dba, dotnet-app-dba, and nodejs-app-dba are all reporting data.

### 4.3 Verify Logs

Log in to your Splunk Cloud/Enterprise instance and search the index specified in your splunk-values.yaml to confirm Kubernetes logs are flowing correctly

`index="db_gcp_dev" sourcetype="kube:container:*"`

