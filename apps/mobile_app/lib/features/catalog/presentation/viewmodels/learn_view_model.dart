import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/data/repositories/track_repository.dart';

final tracksProvider = FutureProvider<List<Track>>((ref) {
  final repo = ref.watch(trackRepositoryProvider);
  return repo.getTracks();
});
