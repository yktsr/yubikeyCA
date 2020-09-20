#!/bin/bash


echo hogehoge > target.txt

readonly SO_PATH=/usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so
readonly MODULE_PATH=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
readonly SLOT=slot_0-id_2
readonly PIN_KEY=123456

yubico-piv-tool -a read-certificate -s 9c | openssl x509 -pubkey -noout > public.pem

openssl << EOF 
engine dynamic -pre SO_PATH:$SO_PATH -pre ID:pkcs11 -pre NO_VCHECK:1 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:$MODULE_PATH -pre VERBOSE
dgst -sha1 -engine pkcs11 -keyform engine -sign $SLOT -out sign.sig -passin pass:$PIN_KEY target.txt
EOF

openssl dgst -sha1 -verify public.pem -signature sign.sig target.txt
