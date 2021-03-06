#!/bin/sh

mkdir -p keys

# This step is to generate the original apk signing keystore. 
# If you already have one, simply copy it as keys/orig.p12
openssl genrsa -out orig_key.pem 4096
openssl req -new -x509 -days 1024 -key orig_key.pem \
	-out orig_cert.pem -subj "/CN=SampleAppCert"
openssl pkcs12 -export -in orig_cert.pem -inkey orig_key.pem \
	-password pass:passwd -out keys/orig.p12 -name cert
rm -f orig_key.pem orig_cert.pem

# This step is to generate the OASP key and cert
openssl genrsa -out keys/oasp.key 4096
openssl req -new -x509 -sha256 -days 1024 -key keys/oasp.key \
	-out keys/oasp.cert -subj "/CN=SampleOASPCert"

# This step is to generate the old OASP key/cert pairs
# If you already have existing old OASP keys/certs to upgrade from, place them in keys dir
openssl genrsa -out keys/old1.key 4096
openssl genrsa -out keys/old2.key 4096
openssl req -new -x509 -sha256 -days 1024 -key keys/old1.key \
	-out keys/old1.cert -subj "/CN=SampleOldOASPCert1"
openssl req -new -x509 -sha256 -days 1024 -key keys/old2.key \
	-out keys/old2.cert -subj "/CN=SampleOldOASPCert2"

# Prepare the OASP info
echo $'{\n  "version": 1,\n  "url": "https://oasp.your.domain"\n}' > oasp.json

# Generate OASP server key/cert
# You don't need it if you have your own HTTPS server
# Note that you have to install the cert into Android Credential Storage 
#   in order to make HTTPS communications work. From Android 7 (Nougat),
#   additional change must also be made to the client app: https://android-
#   developers.googleblog.com/2016/07/changes-to-trusted-certificate.html
openssl genrsa -out server/key.pem 4096
openssl req -new -x509 -days 1024 -key server/key.pem -out server/cert.pem \
	-config server/openssl.cnf -extensions v3_ca
