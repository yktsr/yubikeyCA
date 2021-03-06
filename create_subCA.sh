#!/bin/bash
function newCA(){
  local CADIR=$1
  mkdir -p ${CADIR}
  mkdir -p ${CADIR}/certs
  mkdir -p ${CADIR}/crl
  mkdir -p ${CADIR}/newcerts
  mkdir -p ${CADIR}/subcas
  mkdir -p ${CADIR}/subcerts
  mkdir -p -m 700 ${CADIR}/private

  touch ${CADIR}/index.txt
  echo 01 > ${CADIR}/crlnumber
  echo "unique_subject = no" > ${CADIR}/index.txt.attr
}

newCA subcas/subCA
cp ca.conf subcas/subCA
cp subCA_cert.pem subcas/subCA/cacert.pem
