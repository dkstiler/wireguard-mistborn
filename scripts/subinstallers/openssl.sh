#!/bin/bash

KEY_FOLDER="./tls/"
CRT_FILE="cert.crt"
KEY_FILE="cert.key"

CRT_PATH="$KEY_FOLDER/$CRT_FILE"
KEY_PATH="$KEY_FOLDER/$KEY_FILE"

# ensure openssl installed
sudo apt-get install -y openssl

# make folder
mkdir -p $KEY_FOLDER

# generate crt and key
openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:4096 -keyout $KEY_PATH -out $CRT_PATH -subj "/C=US/ST=New York/L=New York/O=cyber5k/OU=mistborn/CN=*.mistborn/emailAddress=mistborn@localhost"

# set permissions
chmod 644 $CRT_PATH
chmod 600 $KEY_PATH
