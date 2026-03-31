import 'package:my_project/data/storage/key_value_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsStorage implements KeyValueStorage {
  SharedPrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  @override
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }
}
