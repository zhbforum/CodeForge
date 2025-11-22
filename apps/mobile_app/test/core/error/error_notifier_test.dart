import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/error/error_notifier.dart';

void main() {
  group('AppErrorNotifier', () {
    test('show sets error and auto-clears after 4 seconds', () {
      fakeAsync((async) {
        final notifier = AppErrorNotifier()..show('Boom');
        expect(notifier.state, isNotNull);
        expect(notifier.state!.message, 'Boom');

        async.elapse(const Duration(seconds: 3));
        expect(notifier.state, isNotNull);
        expect(notifier.state!.message, 'Boom');

        async.elapse(const Duration(seconds: 2));
        expect(notifier.state, isNull);
      });
    });

    test('clear immediately clears error and cancels timer', () {
      fakeAsync((async) {
        final notifier = AppErrorNotifier()..show('Boom');
        expect(notifier.state, isNotNull);

        notifier.clear();
        expect(notifier.state, isNull);

        async.elapse(const Duration(seconds: 5));
        expect(notifier.state, isNull);
      });
    });
  });
}
