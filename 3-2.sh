#!/bin/bash

echo 3.2.1 秘密鍵の作成
MANAGEMENT_KEY=010203040506070801020304050607080102030405060708
yubico-piv-tool -s 9c -a generate -o public.pem -k${MANAGEMENT_KEY}



echo 3.2.2 一時的な自己署名証明書の発行
PIN=123456
yubico-piv-tool -s 9c -S '/CN=test cert/OU=test/O=hogehoge/L=Minato-ku/ST=Tokyo/C=JP' -P ${PIN} -a verify -a selfsign -i public.pem -o cert.pem

openssl x509 -text < cert.pem

echo
read -p "Press enter to continue: "



echo 3.2.3 PIV スロットへの証明書の取り込み
yubico-piv-tool -a import-certificate -s 9c -i cert.pem



echo 3.2.4 ルート認証局の公開鍵証明書を作成する
SO_PATH=/usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so
MODULE_PATH=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
SLOT=slot_0-id_2

openssl << EOF
engine dynamic -pre SO_PATH:$SO_PATH -pre ID:pkcs11 -pre NO_VCHECK:1 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:$MODULE_PATH -pre VERBOSE
req -new -sha256 -x509 -days 3650 -config rootCA.conf -engine pkcs11 -keyform engine -key $SLOT -passin pass:$PIN_KEY -out rootCA_cert.pem
EOF

openssl x509 -text < rootCA_cert.pem

echo
read -p "Press enter to continue: "



echo 3.2.5 PIV スロットの証明書を上書きする
yubico-piv-tool -a import-certificate -s 9c -i rootCA_cert.pem



echo 3.2.6 ルート認証局フォルダの作成
bash create_rootCA.sh
tree --charset=C

echo
read -p "Press enter to continue: "



echo 3.2.7 ルート認証局から CRL を発行する
cd rootCA
OPENSSL_CONF=ca.conf openssl ca -engine pkcs11 -keyfile slot_0-id_2 -keyform engine -gencrl -passin pass:123456 > revoked.crl
openssl crl -text < revoked.crl
