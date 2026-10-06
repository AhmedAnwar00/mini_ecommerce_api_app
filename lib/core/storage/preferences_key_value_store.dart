import 'package:shared_preferences/shared_preferences.dart';

import 'package:mini_ecommerce_app_prompt/core/storage/key_value_store.dart';

class PreferencesKeyValueStore implements KeyValueStore {
  PreferencesKeyValueStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<String?> read(String key) async => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _preferences.remove(key);
  }
}
