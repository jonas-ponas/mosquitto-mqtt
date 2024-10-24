FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    mosquitto \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy the certificate generation script
COPY ./generate_certs.sh /generate_certs.sh
RUN chmod +x /generate_certs.sh

# Copy the Mosquitto configuration file
COPY ./config/mosquitto.conf /mosquitto/config/mosquitto.conf

# Expose Mosquitto on port 8883 (SSL)
EXPOSE 8883

# Start the certificate generation and then Mosquitto
ENTRYPOINT ["/bin/bash", "-c", "/generate_certs.sh && mosquitto -c /mosquitto/config/mosquitto.conf"]
