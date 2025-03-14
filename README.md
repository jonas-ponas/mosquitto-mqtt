# Secure Mosquitto broker

![Mosquitto Logo](https://mosquitto.org/images/mosquitto-text-side-28.png 'Mosquitto')

# Basic Docker setup for a TLS enabled MQTT Server

This project establishes an MQTT broker with TLS and user
authentication. Most actions including the generation of certificates
are performed using GNU make to reduce errors introduced with manual
procedures.

## Setup

Adjust the hostname in the docker-compose.yml to match your IP/Domain

```bash
git clone https://github.com/paddy-314/mosquitto-mqtt.git
cd mosquitto-mqtt

docker compose up -d
```

## Test

1. Verify that the broker is running with `docker compose ps`
2. Subscribe to the /world topic:
```bash
mosquitto_sub -h <ip/fqdn (same as in certificate)> -p 8883 -u admin -P 'password' --cafile /mosquitto/certs/ca.crt --cert /mosquitto/certs/client.crt --key /mosquitto/certs/client.key -t /world
```
3. Manually publish a message:
```bash
mosquitto_pub -h <ip/fqdn (same as in certificate)> -p 8883 -u admin -P 'password' --cafile /mosquitto/certs/ca.crt --cert /mosquitto/certs/client.crt --key /mosquitto/certs/client.key -m hello -t /world
```
4. Verify that the subscriber prints out the `hello` message to the `/world` topic.

## Configuration

The config file is in the file [mosquito.conf](./config/mosquitto.conf)

By default we activated the log and data persistance (logs are in the `log` folder, and data are stored in a docker volume).

## Authentication

### Enable authentication

In the config file, just uncomment the `Authentication` part and then restart the container.
The default user is `admin/password`.

**You always have to restart if you want the modification to be taken in account:**

```bash
docker compose restart
```

### Change user password / create a new user

```bash
docker compose exec mosquitto mosquitto_passwd -b /mosquitto/config/password.txt user password
```

### Delete user

```bash
docker compose exec mosquitto mosquitto_passwd -D /mosquitto/config/password.txt user
```
