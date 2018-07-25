### Crypt Lib Usage:bbuild
#
# A rudimentary encryption library built on openssl.
#
# This library provides interactive encryption pipes, prompting for password
#  to encyrpt/decrypt data.
#
# crypt:encrypt_s and crypt:decrypt_s work with ASCII crypt data. This is useful
#  when storing encrypted data as text, for example password string.
#
# crypt:encrypt and crypt:decrypt:b work with binary data.
#
###/doc

crypt:encrypt() {
    openssl aes-256-cbc -salt
}

crypt:decrypt() {
    openssl aes-256-cbc -d
}

crypt:encrypt_s() {
    openssl aes-256-cbc -a -salt
}

crypt:decrypt_s() {
    openssl aes-256-cbc -a -d
}
