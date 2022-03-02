import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data_provider.dart';

/// Concrete implementation for local hive data provider
class HiveDataProvider implements LocalDataProviderContract {
  bool _initialized = false;
  HiveDataProvider() {
    _databaseInit();
  }

  /// Open Hive connection
  Future<void> _databaseInit() async {
    if (!_initialized) {
      await Hive.initFlutter();
      _initialized = true;
    }
  }

  /// Open and return hive box
  Future<Box> _getBox(String boxName) async {
    if (!_initialized) await _databaseInit();
    Box box;
    if (!Hive.isBoxOpen(boxName)) {
      box = await Hive.openBox(boxName);
    } else {
      box = Hive.box(boxName);
    }
    return box;
  }

  @override
  Future deleteData(
    String table, {
    String? whereClauseValue,
    List? whereClauseArgs,
    List<String>? keys,
  }) async {
    var box = await _getBox(table);
    // empty box
    if (keys == null || keys.isEmpty) {
      await box.clear();
      return;
    }
    await Future.wait(keys.map((key) => box.delete(key)));
    keys.forEach((String key) {
      box.delete(key);
    });
  }

  @override
  Future<void> insertData(String table, Map<dynamic, dynamic> values) async {
    var box = await _getBox(table);
    if (values != null && values.isNotEmpty) {
      values.forEach((k, v) => box.put(k, v));
    }
  }

  @override
  Future<Map<String, dynamic>> readData(
    String table, {
    bool? distinct,
    List<String>? keys,
    List<String>? columns,
    String? whereClauseValue,
    List? whereClauseArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
  }) async {
    var box = await _getBox(table);
    if (keys == null || keys.isEmpty) {
      return Map<String, dynamic>.from(box.toMap());
    }
    var data = <String, dynamic>{};
    keys.forEach((k) => data[k] = box.get(k));
    return data;
  }

  @override
  Future updateData(
    String table,
    Map<String, dynamic> values, {
    String? whereClauseValue,
    List? whereClauseArgs,
  }) async {
    var box = await _getBox(table);
    if (values != null && values.isNotEmpty) {
      values.forEach((k, v) => box.put(k, v));
    }
    return null;
  }

  @override
  Future runRawQuery({String? query, List? arguments}) async {
    return null;
  }

  @override
  Future<void> rawDeleteData(String table, {Map<String, dynamic>? queries}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> rawReadData(String table,
      {Map<String, dynamic>? queries}) {
    throw UnimplementedError();
  }
}
