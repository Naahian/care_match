import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores strings and JSON-compatible maps in platform secure storage.
///
/// Accepts a configured storage instance for platform options or tests.
/// Storage and serialization errors are propagated to the caller.
class StorageService {
  StorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const hasOpenedKey = 'app.hasOpened.v1';

  Future<void> writeString({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  /// Returns null when the key does not exist.
  Future<String?> readString({required String key}) => _storage.read(key: key);

  Future<void> writeBool({required String key, required bool value}) =>
      writeString(key: key, value: value.toString());

  /// Returns null for a missing value. Malformed values are not treated as true.
  Future<bool?> readBool({required String key}) async {
    return switch (await readString(key: key)) {
      null => null,
      'true' => true,
      'false' => false,
      _ => throw const FormatException('Stored value is not a boolean.'),
    };
  }

  /// Returns true for a missing/false flag and records that the app has opened.
  /// Subsequent calls return false. Storage failures propagate to startup.
  Future<bool> checkAndMarkFirstOpen() async {
    final hasOpened = await readBool(key: hasOpenedKey) ?? false;
    if (hasOpened) return false;
    await writeBool(key: hasOpenedKey, value: true);
    return true;
  }

  /// Values must be JSON-compatible (including nested maps and lists).
  Future<void> writeMap({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    final encoded = jsonEncode(value);
    await _storage.write(key: key, value: encoded);
  }

  /// Returns null for a missing key and throws [FormatException] if the stored
  /// value is malformed JSON or is not a JSON object.
  Future<Map<String, dynamic>?> readMap({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;

    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Stored value is not a JSON object.');
    }
    return decoded;
  }

  Future<bool> containsKey({required String key}) =>
      _storage.containsKey(key: key);

  Future<void> delete({required String key}) => _storage.delete(key: key);

  /// Deletes all entries accessible to this configured storage instance.
  Future<void> deleteAll() => _storage.deleteAll();
}
