import 'package:encrypt/encrypt.dart';

class CryptoService {
  static String encryptSecret(String plaintext, String password) {
    final key = Key.fromUtf8(password.padRight(32).substring(0, 32));
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  static String decryptSecret(String encryptedData, String password) {
    try {
      final parts = encryptedData.split(':');
      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);

      final key = Key.fromUtf8(password.padRight(32).substring(0, 32));
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return "Decryption Error: Invalid Password";
    }
  }
}