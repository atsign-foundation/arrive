/// Local Data Provider Interface class
abstract class LocalDataProviderContract {
  Future<void> insertData(String table, Map<String, dynamic> values) async {}

  Future<Map<String, dynamic>> readData(
    String table, {
    bool? distinct,
    List<String>? keys,
    List<String>? columns,
    String? whereClauseValue,
    List<dynamic>? whereClauseArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
  });

  Future updateData(
    String table,
    Map<String, dynamic> values, {
    String? whereClauseValue,
    List<dynamic>? whereClauseArgs,
  }) async {}

  Future deleteData(
    String table, {
    String? whereClauseValue,
    List<dynamic>? whereClauseArgs,
    List<String>? keys,
  }) async {}

  Future<dynamic> runRawQuery({String? query, List<dynamic>? arguments}) async {}

  Future<void> rawDeleteData(
    String table, {
    Map<String, dynamic>? queries,
  }) async {}

  Future<List<Map<String, dynamic>>> rawReadData(
    String table, {
    Map<String, dynamic>? queries,
  });
}
