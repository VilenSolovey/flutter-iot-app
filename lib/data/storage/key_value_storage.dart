abstract class KeyValueStorage {
  Future<bool> setString(String key, String value);

  String? getString(String key);

  Future<bool> remove(String key);
}
