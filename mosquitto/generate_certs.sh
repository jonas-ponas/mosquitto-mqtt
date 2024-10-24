#!/bin/bash
env

IP=$MQTT_IP
SUBJECT="/C=/ST=/L=/O="
SUBJECT_CA="$SUBJECT/OU=CA/CN=$IP"
SUBJECT_SERVER="$SUBJECT/OU=Server/CN=$IP"
SUBJECT_CLIENT="$SUBJECT/OU=Client/CN=$IP"
CERTPATH="/certs"
DAYS="365"

function generate_CA () {
   openssl req -x509 -nodes -sha256 -newkey rsa:2048 -subj "$SUBJECT_CA"  -days "$DAYS" -keyout "$CERTPATH/ca.key" -out "$CERTPATH/ca.crt"
}

function generate_server () {
   openssl req -nodes -sha256 -new -subj "$SUBJECT_SERVER" -keyout "$CERTPATH/server.key" -out "$CERTPATH/server.csr"
   openssl x509 -req -sha256 -in "$CERTPATH/server.csr" -CA "$CERTPATH/ca.crt" -CAkey "$CERTPATH/ca.key" -CAcreateserial -out "$CERTPATH/server.crt" -days "$DAYS"
}

function generate_client () {
   openssl req -new -nodes -sha256 -subj "$SUBJECT_CLIENT" -out "$CERTPATH/client.csr" -keyout "$CERTPATH/client.key"
   openssl x509 -req -extfile <(printf "subjectAltName=IP.1:$IP")  -sha256 -in "$CERTPATH/client.csr" -CA "$CERTPATH/ca.crt" -CAkey "$CERTPATH/ca.key" -CAcreateserial -out "$CERTPATH/client.crt" -days "$DAYS"
}

mkdir -p $CERTPATH
generate_CA
generate_server
generate_client
chmod +r $CERTPATH -R
