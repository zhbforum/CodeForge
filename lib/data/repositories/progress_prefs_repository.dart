import 'package:mobile_app/data/repositories/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPrefsRepository implements ProgressRepository {
  static const _kKey = 'completed_node_ids';
  @override
  Future<Set<String>> loadCompleted() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_kKey) ?? const <String>[]).toSet();
  }

  @override
  Future<void> markCompleted(String id) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_kKey) ?? <String>[];
    if (!list.contains(id)) {
      list.add(id);
      await p.setStringList(_kKey, list);
    }
  }

  @override
  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kKey);
  }
}
