import 'package:shared_preferences/shared_preferences.dart';

class MyReportsLocalDatasource {
  const MyReportsLocalDatasource();

  static const _key = 'my_citizen_report_ids';

  Future<Set<String>> readIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<void> addId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key)?.toSet() ?? {};
    ids.add(id);
    await prefs.setStringList(_key, ids.toList());
  }

  Future<void> removeId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key)?.toSet() ?? {};
    ids.remove(id);
    await prefs.setStringList(_key, ids.toList());
  }
}
