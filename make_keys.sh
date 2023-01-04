#!/bin/bash

IP=$1
SUBJECT="/C=/ST=/L=/O="
SUBJECT_CA="$SUBJECT/OU=CA/CN=$IP"
SUBJECT_SERVER="$SUBJECT/OU=Server/CN=$IP"
SUBJECT_CLIENT="$SUBJECT/OU=Client/CN=$IP"
CERTPATH="./config/certs"
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
   openssl x509 -req -sha256 -in "$CERTPATH/client.csr" -CA "$CERTPATH/ca.crt" -CAkey "$CERTPATH/ca.key" -CAcreateserial -out "$CERTPATH/client.crt" -days "$DAYS"
}

rm -rf $CERTPATH
mkdir $CERTPATH &> /dev/null
generate_CA
generate_server
generate_client
rm -rf /mqtt
mkdir /mqtt &> /dev/null
cp -R $CERTPATH /mqtt
