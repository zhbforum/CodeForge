import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef CurrentSessionGetter = Session? Function();

@visibleForTesting
final authStateStreamProvider = Provider<Stream<AuthState>>(
  (ref) => AppSupabase.client.auth.onAuthStateChange,
);

@visibleForTesting
final currentSessionGetterProvider = Provider<CurrentSessionGetter>(
  (ref) =>
      () => Supabase.instance.client.auth.currentSession,
);

final authRefreshProvider = Provider<ChangeNotifier>((ref) {
  final notifier = _AuthRefreshNotifier(
    ref.read(authStateStreamProvider),
    ref.read(currentSessionGetterProvider),
  );
  ref.onDispose(notifier.dispose);
  return notifier;
});

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(
    Stream<AuthState> authStream,
    CurrentSessionGetter getCurrentSession,
  ) : _getCurrentSession = getCurrentSession,
      _sub = authStream.listen((_) {}) {
    final cached = _getCurrentSession();
    _value = AsyncValue.data(cached);

    _sub
      ..onData((AuthState s) {
        try {
          final ses = s.session ?? _getCurrentSession();
          _value = AsyncValue.data(ses);
        } catch (e, st) {
          _value = AsyncValue.error(e, st);
        }
        notifyListeners();
      })
      ..onError((Object e, StackTrace st) {
        _value = AsyncValue.error(e, st);
        notifyListeners();
      });
  }

  final StreamSubscription<AuthState> _sub;
  final CurrentSessionGetter _getCurrentSession;

  AsyncValue<Session?> _value = const AsyncValue.loading();
  AsyncValue<Session?> get value => _value;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
