import 'dart:convert';

import 'package:care_match/core/services/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService service;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    service = StorageService();
  });

  test('preserves empty strings, whitespace, and Unicode', () async {
    for (final value in ['', ' token ', 'বাংলা']) {
      await service.writeString(key: 'token', value: value);
      expect(await service.readString(key: 'token'), value);
    }
  });

  test('booleans round-trip and missing values return null', () async {
    expect(await service.readBool(key: 'flag'), isNull);
    for (final value in [false, true]) {
      await service.writeBool(key: 'flag', value: value);
      expect(await service.readBool(key: 'flag'), value);
    }
    await service.writeString(key: 'flag', value: 'invalid');
    await expectLater(service.readBool(key: 'flag'), throwsFormatException);
  });

  for (final initialValue in [null, false, true]) {
    test(
      'first-open check records true for initial value $initialValue',
      () async {
        if (initialValue != null) {
          await service.writeBool(
            key: StorageService.hasOpenedKey,
            value: initialValue,
          );
        }
        expect(await service.checkAndMarkFirstOpen(), initialValue != true);
        expect(
          await service.readBool(key: StorageService.hasOpenedKey),
          isTrue,
        );
        expect(await StorageService().checkAndMarkFirstOpen(), isFalse);
      },
    );
  }

  test('round-trips nested JSON maps with mixed value types', () async {
    final value = <String, dynamic>{
      'name': 'Patient',
      'age': 30,
      'verified': true,
      'optional': null,
      'details': {
        'scores': [1, 2.5],
      },
    };
    await service.writeMap(key: 'profile', value: value);
    expect(await service.readMap(key: 'profile'), value);
    await service.writeMap(key: 'profile', value: {});
    expect(await service.readMap(key: 'profile'), isEmpty);
  });

  test('missing keys return null for both readers', () async {
    expect(await service.readString(key: 'missing'), isNull);
    expect(await service.readMap(key: 'missing'), isNull);
  });

  test('rejects malformed JSON and JSON values that are not maps', () async {
    for (final value in ['invalid', '[]', 'null', '42', '"text"']) {
      await service.writeString(key: 'profile', value: value);
      await expectLater(
        service.readMap(key: 'profile'),
        throwsA(isA<FormatException>()),
      );
    }
  });

  test('failed JSON encoding preserves the previously stored value', () async {
    await service.writeMap(key: 'profile', value: {'name': 'Patient'});
    await expectLater(
      service.writeMap(key: 'profile', value: {'unsupported': Object()}),
      throwsA(isA<JsonUnsupportedObjectError>()),
    );
    expect(await service.readMap(key: 'profile'), {'name': 'Patient'});
  });

  test(
    'supports existence checks, individual deletion, and clearing',
    () async {
      await service.writeString(key: 'token', value: 'secret');
      await service.writeMap(key: 'profile', value: {'name': 'Patient'});
      expect(await service.containsKey(key: 'token'), isTrue);
      await service.delete(key: 'token');
      expect(await service.containsKey(key: 'token'), isFalse);
      expect(await service.readMap(key: 'profile'), isNotNull);
      await service.deleteAll();
      expect(await service.readMap(key: 'profile'), isNull);
    },
  );
}
