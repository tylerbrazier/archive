#!/usr/bin/env ruby

# TODO encrypt returns strange characters!

require 'openssl'

class Crypt
    def initialize(salt_bytes, iv_bytes, iter)
        @cipher = OpenSSL::Cipher.new("AES-256-CBC")
        @salt_bytes = salt_bytes
        @iv_bytes = iv_bytes
        @iter = iter
    end

    def encrypt(plaintext, password)
        @cipher.encrypt
        salt = OpenSSL::Random.random_bytes(@salt_bytes).unpack('H*')[0]
        iv = OpenSSL::Random.random_bytes(@iv_bytes).unpack('H*')[0]
        key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(
                password, salt, @iter, @cipher.key_len)
        @cipher.iv = iv
        @cipher.key = key
        encrypted = salt
        encrypted << iv
        encrypted << @cipher.update(plaintext)
        encrypted << @cipher.final
        return encrypted
    end

    def decrypt(ciphertext, password)
        @cipher.decrypt
        salt_len = @salt_bytes*2
        iv_len = @iv_bytes*2
        salt = ciphertext[0, salt_len]
        iv = ciphertext[salt_len, iv_len]
        encrypted = ciphertext[(salt_len + iv_len)..-1]
        key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(
                password, salt, @iter, @cipher.key_len)
        @cipher.iv = iv
        @cipher.key = key
        decrypted = @cipher.update(encrypted)
        decrypted << @cipher.final
        return decrypted
    end
    
    def inspect
        #"#<Crypt:#{object_id}>"
        "Nothing to see here."
    end
end

# test code
c = Crypt.new(16, 16, 20000)
100.times do
    #pass = "some test password"
    #puts c.decrypt(c.encrypt("attack at dawn", pass), pass)
    puts c.encrypt("attack at dawn", "password")
    puts
end

