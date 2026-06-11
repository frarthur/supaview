import 'package:hive_flutter/hive_flutter.dart';

import 'package:supaview/core/constants/app_constants.dart';

class HiveService {
  HiveService._();

  static late Box<dynamic> _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(AppConstants.hiveBoxName);
  }

  static Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  static dynamic get(String key) {
    return _box.get(key);
  }

  static Future<void> delete(String key) async {
    await _box.delete(key);
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  static Future<void> close() async {
    await _box.close();
  }
}
