#!/bin/bash

TOP_DIR=${PWD}
ROOTCA_DIR=${TOP_DIR}/rootCA
SUBCA_DIR=${ROOTCA_DIR}/subcas/subCA
cd ${SUBCA_DIR}

echo 3.4.1 秘密鍵と証明書署名要求の作成
openssl req -new -nodes -sha256 -keyout ee.key -out ee_csr.pem -subj "/C=JP/ST=Tokyo/L=Minato-ku/O=Electric-Sheep/OU=Electic-Sheep/CN=exmaple.com" -addext 'subjectAltName = DNS:example.com,DNS:www.example.com,DNS:localhost, IP:192.168.1.1,IP:192.168.1.2'

echo 3.4.2 中間認証局による署名
cp ${TOP_DIR}/ee.conf ./
OPENSSL_CONF=ca.conf openssl ca -engine pkcs11 -keyfile slot_0-id_1 -keyform engine -passin pass:123456 -create_serial -extfile ee.conf -in ee_csr.pem > ee_cert.pem
openssl x509 -text -nout < ee_cert.pem

tree --charset=C ${TOP_DIR}
echo
read -p "Press enter to continue: "

openssl x509 -text -noout < ee_cert.pem
echo
read -p "Press enter to continue: "


echo 3.4.3 証明書チェーンの接続
cat <(openssl x509 < cacert.pem) <(openssl x509 < ee_cert.pem) > ee_chain.pem
cat ee_chain.pem
echo
read -p "Press enter to continue: "


echo 3.4.4 EE証明書の失効
PIN=123456
OPENSSL_CONF=ca.conf openssl ca -engine pkcs11 -keyfile slot_0-id_1 -keyform engine -passin pass:${PIN} -revoke ee_cert.pem
OPENSSL_CONF=ca.conf openssl ca -engine pkcs11 -keyfile slot_0-id_1 -keyform engine -gencrl -passin pass:${PIN} > revoked.crl
openssl crl -text < revoked.crl
