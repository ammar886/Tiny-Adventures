import 'package:shared_preferences/shared_preferences.dart';

/// Thin abstraction over local key-value storage for testability and offline safety.
abstract class StorageService {
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);

  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);

  Future<List<String>?> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
}

/// Local storage backed by [SharedPreferences].
class SharedPreferencesStorageService implements StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    final prefs = await _instance;
    await prefs.setInt(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _instance;
    return prefs.getStringList(key);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await _instance;
    await prefs.setStringList(key, value);
  }
}
