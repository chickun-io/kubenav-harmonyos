import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static final Storage _instance = Storage._internal();
  static const MethodChannel _ohosChannel = MethodChannel('kubenav.io/storage');

  factory Storage() {
    return _instance;
  }

  Storage._internal();

  final bool _ohos = Platform.operatingSystem == 'ohos';
  FlutterSecureStorage? _storage;

  Future<void> init() async {
    if (_ohos) {
      return;
    }
    _storage = const FlutterSecureStorage();
  }

  Future<void> write(String key, String value) async {
    if (_ohos) {
      await _ohosChannel.invokeMethod<void>('write', <String, String>{
        'key': key,
        'value': value,
      });
      return;
    }
    await _storage?.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    if (_ohos) {
      return _ohosChannel.invokeMethod<String>('read', <String, String>{
        'key': key,
      });
    }
    return await _storage?.read(key: key);
  }

  Future<void> delete(String key) async {
    if (_ohos) {
      await _ohosChannel.invokeMethod<void>('delete', <String, String>{
        'key': key,
      });
      return;
    }
    return await _storage?.delete(key: key);
  }
}
