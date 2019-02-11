##bash-libs: crypt.sh @ %COMMITHASH%

### Crypt Lib Usage:bbuild
#
# A rudimentary encryption library built on openssl, for using symmetrical keys,
#  aka "password-based encryption."
#
# It is worth noting that OpenSSL uses a SHA256 hash with only 1 iteration to
#  generate the password hash: https://bit.ly/2Ogxfxq
#
# This library provides interactive encryption pipes, prompting for password
#  to encyrpt/decrypt data.
#
###/doc

### crypt:encrypt Usage:bbuild
# Encrypt stdin to binary stdout
#
###/doc
crypt:encrypt() {
    openssl aes-256-cbc -salt
}

### crypt:decrypt Usage:bbuild
# Decrypt binary stdin to original stdout
#
###/doc
crypt:decrypt() {
    openssl aes-256-cbc -d
}

### crypt:encrypt_s Usage:bbuild
# Encrypt stdin to ASCII stdout
#
###/doc
crypt:encrypt_s() {
    openssl aes-256-cbc -a -salt
}

### crypt:decrypt_s Usage:bbuild
# Decrypt ASCII stdin to original stdout
#
###/doc
crypt:decrypt_s() {
    openssl aes-256-cbc -a -d
}
