# Stage 1: Build the .NET app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["manual-dotnet.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Final Runtime Image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app
COPY --from=build /app/publish .

# Install dependencies: added 'unzip' to handle the new asset format
RUN apk add --no-cache icu-libs libc6-compat strace unzip wget

# Download and Install Splunk OTel .NET Agent 
# We use the specific version v1.13.0 to ensure stability
RUN wget https://github.com/signalfx/splunk-otel-dotnet/releases/download/v1.13.0/splunk-opentelemetry-dotnet-linux-musl-x64.zip && \
    mkdir -p /otel && \
    unzip splunk-opentelemetry-dotnet-linux-musl-x64.zip -d /otel && \
    rm splunk-opentelemetry-dotnet-linux-musl-x64.zip

# --- MANUAL INSTRUMENTATION VARIABLES ---
ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={918728DD-6696-485A-A80B-18E0319D8DEC}
ENV CORECLR_PROFILER_PATH=/otel/linux-musl-x64/OpenTelemetry.AutoInstrumentation.Native.so
ENV DOTNET_ADDITIONAL_DEPS=/otel/AdditionalDeps
ENV DOTNET_SHARED_STORE=/otel/store
ENV DOTNET_STARTUP_HOOKS=/otel/net/OpenTelemetry.AutoInstrumentation.StartupHook.dll
ENV OTEL_DOTNET_AUTO_HOME=/otel
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

EXPOSE 8080
ENTRYPOINT ["dotnet", "manual-dotnet.dll"]
