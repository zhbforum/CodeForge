import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/data/repositories/track_repository.dart';

final lessonsProvider = FutureProvider.family<List<Lesson>, TrackId>((
  ref,
  trackId,
) {
  final repo = ref.watch(trackRepositoryProvider);
  return repo.getLessons(trackId);
});
