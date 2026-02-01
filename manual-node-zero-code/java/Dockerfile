# Stage 1: Build the Java code
# Using Temurin JDK for building
FROM eclipse-temurin:17-jdk-focal AS build
WORKDIR /app
COPY Main.java .
RUN javac Main.java

# Stage 2: Final Runtime Image
# Using Temurin JRE Alpine for a lightweight, secure runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# 1. Download the Splunk Java Agent
ADD https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent.jar /splunk-otel-javaagent.jar
RUN chmod -R go+r /splunk-otel-javaagent.jar

# 2. Copy the compiled class from the build stage
COPY --from=build /app/Main.class .

# 3. Expose the app port
EXPOSE 8080

# 4. Start the app with the Java Agent
# We use the -javaagent flag to hook the Splunk SDK into the JVM
CMD ["java", "-javaagent:/splunk-otel-javaagent.jar", "-Dsplunk.profiler.enabled=true", "Main"]
