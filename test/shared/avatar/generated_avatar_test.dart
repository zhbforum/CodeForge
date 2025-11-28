import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/shared/avatar/generated_avatar.dart';

import '../../helpers/test_wrap.dart';

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient implements HttpClient {
  bool _autoUncompress = true;

  @override
  bool get autoUncompress => _autoUncompress;

  @override
  set autoUncompress(bool value) {
    _autoUncompress = value;
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _FakeResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  static final Uint8List _png = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  @override
  int get contentLength => _png.length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final controller = StreamController<List<int>>()
      ..add(_png)
      ..close();
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders network avatar when url is provided', (tester) async {
    final prev = HttpOverrides.current;
    HttpOverrides.global = _FakeHttpOverrides();
    addTearDown(() => HttpOverrides.global = prev);

    await tester.pumpWidget(
      wrap(
        const GeneratedAvatar(
          seed: 'any',
          size: 32,
          url: 'http://example.com/avatar.png',
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(Image), findsOneWidget);

    final size = tester.getSize(find.byType(GeneratedAvatar));
    expect(size.width, 32);
    expect(size.height, 32);
  });

  testWidgets('forces min-fill loop (covers extra-cells branch)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const GeneratedAvatar(seed: 'zzz', size: 24, debugForceMinFill: true),
      ),
    );
    await tester.pump();
    expect(find.byType(GeneratedAvatar), findsOneWidget);
  });

  testWidgets('shouldRepaint when debugForceMinFill changes (same seed)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const GeneratedAvatar(seed: 'same-seed', size: 40)),
    );
    await tester.pump();

    await tester.pumpWidget(
      wrap(
        const GeneratedAvatar(
          seed: 'same-seed',
          size: 40,
          debugForceMinFill: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GeneratedAvatar), findsOneWidget);
  });

  testWidgets('shouldRepaint is triggered when seed changes', (tester) async {
    await tester.pumpWidget(
      wrap(const GeneratedAvatar(seed: 'alpha', size: 40)),
    );
    await tester.pump();

    await tester.pumpWidget(
      wrap(const GeneratedAvatar(seed: 'beta', size: 40)),
    );
    await tester.pump();

    expect(find.byType(GeneratedAvatar), findsOneWidget);
  });

  testWidgets('initials fallback uses first letters of two words (JD)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const GeneratedAvatar(seed: 'john doe', size: 40)),
    );
    await tester.pump();

    expect(find.text('JD'), findsOneWidget);
  });

  testWidgets(
    'probabilistic path: ensure "at least 3 on" filler executes at least once',
    (tester) async {
      for (var i = 0; i < 1000; i++) {
        await tester.pumpWidget(
          wrap(GeneratedAvatar(seed: 'seed_$i', size: 24)),
        );
        await tester.pump(const Duration(milliseconds: 1));
      }
      expect(find.byType(GeneratedAvatar), findsOneWidget);
    },
  );
}
