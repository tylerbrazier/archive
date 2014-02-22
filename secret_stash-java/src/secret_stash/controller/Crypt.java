/*
 * TODO Use the HMAC to determine if password is correct
 */
package secret_stash.controller;

import java.security.SecureRandom;
import java.security.spec.KeySpec;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;

public class Crypt {

    public static final int IV_SIZE = 16;   // in bytes
    public static final int SALT_SIZE = 16; // in bytes
    public static final int ITER = 20000;   // number of iterations
    public static final int KEY_LEN = 256;

    private Cipher cipher;

    public Crypt() {
        try { cipher = Cipher.getInstance("AES/CBC/PKCS5Padding"); }
        catch (Exception e) {} // this should never happen
    }


    public String encrypt(String plaintext, String password) throws Exception {
        SecureRandom random = new SecureRandom();
        StringBuilder builder = new StringBuilder();

        // generate salt
        byte[] salt = new byte[SALT_SIZE];
        random.nextBytes(salt); // fill salt with random bytes

        // generate iv
        byte[] iv = new byte[IV_SIZE];
        random.nextBytes(iv);

        // generate key
        SecretKey key = genKey(password, salt);

        // run the cipher using the key and iv
        cipher.init(Cipher.ENCRYPT_MODE, key, new IvParameterSpec(iv));
        byte[] encrypted = cipher.doFinal(plaintext.getBytes("UTF-8"));

        // build the result, which includes salt, iv, and the cipher text
        builder.append(printHexBinary(salt));
        builder.append(printHexBinary(iv));
        builder.append(printHexBinary(encrypted));
        return builder.toString();
    }


    public String decrypt(String ciphertext, String password) throws Exception {
        // extract salt, iv, and encrypted text
        int ivIndex = SALT_SIZE*2;
        int encIndex = SALT_SIZE*2 + IV_SIZE*2;
        String saltString = ciphertext.substring(0, ivIndex);
        String ivString = ciphertext.substring(ivIndex, encIndex);
        String encString = ciphertext.substring(encIndex, ciphertext.length());

        byte[] salt = parseHexBinary(saltString);
        byte[] iv = parseHexBinary(ivString);
        byte[] encrypted = parseHexBinary(encString);

        // generate key
        SecretKey key = genKey(password, salt);

        cipher.init(Cipher.DECRYPT_MODE, key, new IvParameterSpec(iv));
        String plaintext = new String(cipher.doFinal(encrypted), "UTF-8");

        return plaintext;
    }


    private SecretKey genKey(String password, byte[] salt) throws Exception {
        KeySpec spec;
        SecretKeyFactory factory;
        spec = new PBEKeySpec(password.toCharArray(), salt, ITER, KEY_LEN);
        factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
        SecretKey temp = factory.generateSecret(spec);
        return new SecretKeySpec(temp.getEncoded(), "AES");
    }

    /*  javax.xml.bind.DatatypeConverter provides methods
     *  toHexString(byte[] array) and toByteArray(String s)
     *  to convert byte arrays to strings and vice versa.
     *  Since javax.xml.bind.DatatypeConverter is not available
     *  in the Android SDKs by default, this class provides the
     *  exact same functionality as it borrows source code from
     *  DatatypeConverter. The original implementation can be found at
     *  http://www.docjar.com/html/api/com/sun/xml/internal/bind/DatatypeConverterImpl.java.html
     */
    private static byte[] parseHexBinary(String s) {
        final int len = s.length();
        // "111" is not a valid hex encoding.
        if( len%2 != 0 )
            throw new IllegalArgumentException(
                    "hexBinary needs to be even-length: "+s);

        byte[] out = new byte[len/2];

        for( int i=0; i<len; i+=2 ) {
            int h = hexToBin(s.charAt(i  ));
            int l = hexToBin(s.charAt(i+1));
            if( h==-1 || l==-1 )
                throw new IllegalArgumentException(
                        "contains illegal character for hexBinary: "+s);
            out[i/2] = (byte)(h*16+l);
        }
        return out;
    }

    private static int hexToBin( char ch ) {
        if( '0'<=ch && ch<='9' )    return ch-'0';
        if( 'A'<=ch && ch<='F' )    return ch-'A'+10;
        if( 'a'<=ch && ch<='f' )    return ch-'a'+10;
        return -1;
    }

    private static String printHexBinary(byte[] data) {
        final char[] hexCode = "0123456789ABCDEF".toCharArray();
        StringBuilder r = new StringBuilder(data.length*2);
        for ( byte b : data) {
            r.append(hexCode[(b >> 4) & 0xF]);
            r.append(hexCode[(b & 0xF)]);
        }
        return r.toString();
    }
}
