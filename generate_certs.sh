#!/bin/sh
# env

SUBJECT="/C=/ST=/L=/O="
SUBJECT_CA="$SUBJECT/OU=CA/CN=$IP"
SUBJECT_SERVER="$SUBJECT/OU=Server/CN=$IP"
SUBJECT_CLIENT="$SUBJECT/OU=Client/CN=$IP"
CERTPATH="/certificates"
DAYS="365"


if [ -z "$HOSTS" ]; then
    echo "Error: HOSTS environment variable is not set."
    exit 1
fi

SAN_ENTRIES=""
i=1

IFS=','
for host in $HOSTS; do
    if [ -n "$SAN_ENTRIES" ]; then
        SAN_ENTRIES="$SAN_ENTRIES, "
    fi
    SAN_ENTRIES="${SAN_ENTRIES}DNS.$i:$host"
    i=$((i+1))
done

echo "$SAN_ENTRIES"

echo "Hosts: $HOSTS"
echo "SAN-Entries: $SAN_ENTRIES"

function generate_CA () {
   openssl req -x509 -nodes -sha256 -newkey rsa:2048 -subj "$SUBJECT_CA"  -days "$DAYS" -keyout "$CERTPATH/ca.key" -out "$CERTPATH/ca.crt"
}

function generate_server () {
   openssl req -nodes -sha256 -new -subj "$SUBJECT_SERVER" -keyout "$CERTPATH/server.key" -out "$CERTPATH/server.csr"
   openssl x509 -req -extfile <(printf "subjectAltName=$SAN_ENTRIES") -sha256 -in "$CERTPATH/server.csr" -CA "$CERTPATH/ca.crt" -CAkey "$CERTPATH/ca.key" -CAcreateserial -out "$CERTPATH/server.crt" -days "$DAYS"
}

function generate_client () {
   openssl req -new -nodes -sha256 -subj "$SUBJECT_CLIENT" -out "$CERTPATH/client.csr" -keyout "$CERTPATH/client.key"
   openssl x509 -req -sha256 -in "$CERTPATH/client.csr" -CA "$CERTPATH/ca.crt" -CAkey "$CERTPATH/ca.key" -CAcreateserial -out "$CERTPATH/client.crt" -days "$DAYS"
}

if [[ -f "$CERTPATH/ca.crt" && -f "$CERTPATH/server.crt" && -f "$CERTPATH/server.key" ]]; then
   echo "Found ca.crt, server.crt & server.key. No need to generate (Delete files to force recreate)."
else 
   echo "Did not find ca.crt, server.crt & server.key. Generating new certificates..."

   mkdir -p $CERTPATH
   generate_CA
   generate_server
   generate_client
   chmod +r $CERTPATH -R
   fi




