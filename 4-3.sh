#!/bin/bash


echo hogehoge > target.txt

readonly SO_PATH=/usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so
readonly MODULE_PATH=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
readonly SLOT=slot_0-id_2
readonly PIN_KEY=123456

yubico-piv-tool -a read-certificate -s 9c | openssl x509 -pubkey -noout > public.pem

openssl rsautl -encrypt -pubin -inkey public.pem -in target.txt -out target.encrypted

openssl << EOF
engine dynamic -pre SO_PATH:$SO_PATH -pre ID:pkcs11 -pre NO_VCHECK:1 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:$MODULE_PATH -pre VERBOSE
rsautl -decrypt -engine pkcs11 -keyform engine -inkey $SLOT -passin pass:$PIN_KEY -in target.encrypted
EOF
