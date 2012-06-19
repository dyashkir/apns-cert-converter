if [ $# -ne 3 ]
then
echo "Error in $0 - Invalid Argument Count"
echo "Syntax: $0 request_cer_file p12_file app_cer_file output_filename"
echo "  - request_cer_file      is the request file you sent to apple"
echo "  - p12_file          is found in your keychain (it's the private key)"
echo "  - app_cer_file          is found on App ID screen from Apple"
else

reqFile=$1
p12File=$2
cerFile=$3

certPEM='apn_cert.pem'
pKeyPEM='apn_pkey.pem'
pKeyNoEncPEM='apn_pkey_noenc.pem'
p12FileOut='apn_cert_key.p12'

# remove old
rm $certPEM
rm $pKeyPEM
rm $pKeyNoEncPEM
rm $p12FileOut

#convert *.cer (der format) to pem
openssl x509 -in $cerFile -inform DER -out $certPEM -outform PEM

#convert p12 private key to pem (requires the input of a minimum 4 char password)
openssl pkcs12 -nocerts -out $pKeyPEM -in $p12File

# if you want remove password from the private key
openssl rsa -out $pKeyNoEncPEM -in $pKeyPEM

#take the certificate and the key (with or without password) and create a PKCS#12 format file
openssl pkcs12 -export -in $certPEM -inkey $pKeyNoEncPEM -certfile $reqFile  -name "apn_identity" -out $p12FileOut

#
#   
#   If all things worked then the following should work as a test
#   openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert apn_cert.pem -key apn_pkey_noenc.pem 
#
#
echo "Looks like everything was successful"
echo "Test command:"
echo "openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert apn_cert.pem -key apn_pkey_noenc.pem"
echo
fi
