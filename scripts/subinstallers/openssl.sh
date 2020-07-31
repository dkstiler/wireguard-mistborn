#!/bin/bash

KEY_FOLDER="/opt/mistborn_volumes/base/tls/"
CRT_FILE="cert.crt"
KEY_FILE="cert.key"

CRT_PATH="$KEY_FOLDER/$CRT_FILE"
KEY_PATH="$KEY_FOLDER/$KEY_FILE"

# ensure openssl installed
sudo -E apt-get install -y openssl

# make folder
sudo -E mkdir -p $KEY_FOLDER

# clean old crt and key
sudo -E rm -f ${KEY_FOLDER}/*

# generate crt and key
sudo -E openssl req -x509 -sha256 -nodes -days 397 -newkey rsa:4096 -keyout $KEY_PATH -out $CRT_PATH -addext "subjectAltName = DNS:*.mistborn" -addext extendedKeyUsage=serverAuth -subj "/C=US/ST=New York/L=New York/O=cyber5k/OU=mistborn/CN=*.mistborn/emailAddress=mistborn@localhost"

# set permissions
sudo -E chown -R mistborn:mistborn ${KEY_FOLDER}
chmod 644 $CRT_PATH
chmod 600 $KEY_PATH
