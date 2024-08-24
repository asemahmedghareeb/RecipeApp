import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage Storage =const  FlutterSecureStorage();
  writeSecureDate(String key, String value) async {
    await Storage.write(key: key, value: value);
  }

  readSecureDate(String key) async {
    String value = await Storage.read(key: key) ?? "no Key was found";
    return value;
  }

  deleteSecureData(String key) async {
    await Storage.delete(key: key);
  }
}
