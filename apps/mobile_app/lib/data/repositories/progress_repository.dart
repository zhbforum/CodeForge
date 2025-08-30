abstract class ProgressRepository {
  Future<Set<String>> loadCompleted();
  Future<void> markCompleted(String nodeId);
  Future<void> reset();
}
