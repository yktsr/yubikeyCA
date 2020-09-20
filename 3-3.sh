#!/bin/bash

TOP_DIR=${PWD}
ROOTCA_DIR=${TOP_DIR}/rootCA
cd ${ROOTCA_DIR}
echo 3.3.1 秘密鍵の作成
MANAGEMENT_KEY=010203040506070801020304050607080102030405060708
yubico-piv-tool -s 9a -a generate -o subCA_public.pem -k${MANAGEMENT_KEY}


echo 3.3.2 証明書署名要求の作成
PIN=123456
yubico-piv-tool -s 9a -a verify-pin -a request-certificate -P ${PIN} -S '/CN=Internal Sub CA/OU=Electric-Sheep/O=Electric-Sheep/L=Minato-ku/ST=Tokyo/C=JP' -i subCA_public.pem -o subCA_csr.pem
rm subCA_public.pem


echo 3.3.3 ルート認証局による署名
PIN=123456
cp ${TOP_DIR}/subCA.conf ./
OPENSSL_CONF=ca.conf openssl ca -engine pkcs11 -keyfile slot_0-id_2 -keyform engine -passin pass:${PIN} -create_serial -extfile subCA.conf -in subCA_csr.pem -batch > subCA_cert.pem

openssl x509 -noout -text <  subCA_cert.pem
echo
read -p "Press enter to continue: "


echo 3.3.4 PIVスロットへの証明書の取り込み
yubico-piv-tool -a import-certificate -s 9a -i subCA_cert.pem


echo 3.3.5 中間認証局フォルダの作成
cp ${TOP_DIR}/create_subCA.sh ./
bash create_subCA.sh

tree --charset=C
echo
read -p "Press enter to continue: "


echo 3.3.6 中間認証局からCRLを発行する
SUBCA_DIR=${ROOTCA_DIR}/subcas/subCA
cd ${SUBCA_DIR}
PIN=123456
OPENSSL_CONF=ca.conf openssl ca -engine pkcs11 -keyfile slot_0-id_1 -keyform engine -gencrl -passin pass:${PIN} > revoked.crl
openssl crl -text < revoked.crl
