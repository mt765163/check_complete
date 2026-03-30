import 'package:hive_flutter/hive_flutter.dart';

class HiveCrudService {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box> openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Future<void> put(String boxName, String key, Map<String, dynamic> value, {bool onlyIfAbsent = false}) async {
    final box = await openBox(boxName);
    if (onlyIfAbsent && box.containsKey(key)) return;
    await box.put(key, value);
  }



  Future<Map<String, dynamic>?> get(String boxName, String key) async {
    final box = await openBox(boxName);
    final value = box.get(key);
    if (value == null) return null;
    return Map<String, dynamic>.from(value);
  }


  Future<Map<String, Map<String, dynamic>>> getAll(String boxName) async {
    final box = await openBox(boxName);
    return {
      for (var key in box.keys)
        key.toString(): Map<String, dynamic>.from(box.get(key))
    };
  }


  Future<void> delete(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }


  Future<void> deleteAll(String boxName) async {
    final box = await openBox(boxName);
    await box.clear();
  }


  Future<bool> exists(String boxName, String key) async {
    final box = await openBox(boxName);
    return box.containsKey(key);
  }


  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }
}