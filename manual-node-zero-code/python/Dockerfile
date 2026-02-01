FROM python:3.9

WORKDIR /app

# Install Splunk OTel and Flask
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir flask splunk-opentelemetry[all]

# Install the bootstrap instrumentors
RUN opentelemetry-bootstrap -a install

COPY app.py .

EXPOSE 5000

# Use the wrapper command to start the app
# This automatically instruments Flask
CMD ["opentelemetry-instrument", "python", "app.py"]
