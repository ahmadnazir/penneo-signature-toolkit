#!/bin/bash
#
# Convenience functions to validate Penneo signatures
#
# Author: Ahmad Nazir Raja

function random () {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -1
}
export -f random

function extract-certificate () {
    local index=$1
    xmlstarlet \
        sel \
        -N openoces='http://www.openoces.org/2006/07/signature#' \
        -N ds='http://www.w3.org/2000/09/xmldsig#' \
        -t \
        -v \
        "//openoces:signature/ds:Signature/ds:KeyInfo/ds:X509Data[${index}]/ds:X509Certificate/text()" \
        /dev/stdin
}
export -f extract-certificate

function decode() {
    base64 -d $1
}
export -f decode

function set-certificate () {
    # echo
    local index=$1
    local value=${@:2}
    xmlstarlet \
        ed \
        -P \
        -N openoces='http://www.openoces.org/2006/07/signature#' \
        -N ds='http://www.w3.org/2000/09/xmldsig#' \
        --update \
        "//openoces:signature/ds:Signature/ds:KeyInfo/ds:X509Data[${index}]/ds:X509Certificate" \
        --value \
        "${value}" \
        /dev/stdin
}
export -f set-certificate


function fix-certificate-order () {

    local file=/tmp/`random`
    cat /dev/stdin > ${file}

    local intermediate_cert=$(cat ${file} | extract-certificate 1)
    local root_cert=$(cat ${file} | extract-certificate 2)
    local signer_cert=$(cat ${file} | extract-certificate 3)

    cat ${file} | \
        set-certificate 1 "${signer_cert}" | \
        set-certificate 2 "${intermediate_cert}" | \
        set-certificate 3 "${root_cert}"

    rm ${file}
}
export -f fix-certificate-order

# function x509-der () {
#     openssl x509 -in /dev/stdin -inform DER -noout -text
# }
# export -f x509-der

function der-to-pem () {
    openssl x509 -inform der -in /dev/stdin -out /dev/stdout
}
export -f der-to-pem

function verify-chain () {
    local file=/tmp/`random`
    local inter=/tmp/`random`
    local root=/tmp/`random`
    local signer=/tmp/`random`-signer-cert.der

    cat /dev/stdin > ${file}

    cat ${file} | extract-certificate 1 | decode | der-to-pem > ${inter}
    cat ${file} | extract-certificate 2 | decode | der-to-pem > ${root}
    cat ${file} | extract-certificate 3 | decode | der-to-pem > ${signer}

    openssl verify -CAfile ${root} -untrusted ${inter} ${signer}

    rm ${file}
    rm ${inter}
    rm ${root}
    rm ${signer}
}
export -f verify-chain

function cn () {
    openssl x509 -in /dev/stdin -noout -text | grep Subject:
}
export -f cn

function verify-signature-value () {
    local file=/tmp/`random`
    local inter=/tmp/`random`
    local root=/tmp/`random`

    cat /dev/stdin > ${file}

    cat ${file} | extract-certificate 2 | decode > ${inter}
    cat ${file} | extract-certificate 3 | decode > ${root}

    xmlsec1 \
	      --verify \
        --trusted-der ${inter} \
        --trusted-der ${root} \
        ${file}

    rm ${file}
    rm ${inter}
    rm ${root}

}
export -f verify-signature-value

function validate () {
    local file=/tmp/`random`
    cat /dev/stdin > ${file}

    # # verify chain
    # echo
    # echo '-----------------------------'
    # echo ' Verifying Certificate chain '
    # echo '-----------------------------'
    # echo
    # cat ${file} | verify-chain

    # verify chain
    echo
    echo '-----------------------------'
    echo ' Verifying Certificate chain '
    echo '-----------------------------'
    echo
    cat ${file} | verify-chain

    # verify signature value
    echo
    echo '----------------------------------------------------------'
    echo ' Verifying that the signer has signed the sign properties '
    echo '----------------------------------------------------------'
    echo
    cat ${file} | fix-certificate-order | verify-signature-value

    rm ${file}
}
export -f validate

/bin/bash
