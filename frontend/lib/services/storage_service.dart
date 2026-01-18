import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: 'jwt', value: token);
  Future<String?> getToken() => _storage.read(key: 'jwt');
  
  Future<void> saveEncryptionKey(String key) => _storage.write(key: 'enc_key', value: key);
  Future<String?> getEncryptionKey() => _storage.read(key: 'enc_key');

  Future<void> deleteAll() => _storage.deleteAll();
}