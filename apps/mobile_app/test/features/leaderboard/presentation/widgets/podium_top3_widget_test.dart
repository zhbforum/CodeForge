import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/podium_top3.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _FakeHttpClientRequest(url);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void remove(String name, Object value) {}

  @override
  void removeAll(String name) {}

  @override
  List<String>? operator [](String name) => null;

  @override
  void forEach(void Function(String name, List<String> values) action) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.uri);

  @override
  final Uri uri;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  int contentLength = 0;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  Future<HttpClientResponse> close() async {
    final bytes = _bodyFor(uri);
    return _FakeHttpClientResponse(bytes);
  }

  static List<int> _bodyFor(Uri url) {
    final isSvg =
        url.path.endsWith('.svg') ||
        url.path.contains('/svg') ||
        url.query.contains('format=svg');

    if (isSvg) {
      const svg = '''
                  <svg xmlns="http://www.w3.org/2000/svg" width="60" height="60">
                  <circle cx="30" cy="30" r="30" fill="#ff0000" />
                  </svg>
                  ''';
      return utf8.encode(svg);
    }

    const pngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+i7VUAAAAASUVORK5CYII=';
    return base64Decode(pngBase64);
  }

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {}

  @override
  Future<void> flush() async {}

  @override
  void write(Object? obj) {}

  @override
  // ignore: strict_raw_type : it needs to be removed because its quite terrible
  void writeAll(Iterable objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? obj = '']) {}

  Future<void> closeSink() => close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse(this._bytes);

  final List<int> _bytes;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _bytes.length;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  String get reasonPhrase => 'OK';

  bool get compressed => false;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_bytes]).listen(
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

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  LeaderboardEntry makeEntry({
    required int rank,
    required String displayName,
    required int level,
    String? avatarUrl,
    String leagueName = 'Bronze',
    int seasonExp = 1000,
    int totalExp = 2000,
  }) {
    return LeaderboardEntry(
      rank: rank,
      displayName: displayName,
      avatarUrl: avatarUrl,
      level: level,
      leagueName: leagueName,
      seasonExp: seasonExp,
      totalExp: totalExp,
    );
  }

  Widget wrap(Widget child, {bool dark = false}) {
    return MaterialApp(
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: child),
    );
  }

  testWidgets(
    'PodiumTop3 (dark): svg avatars hit all svg branches and render svgpicture',
    (tester) async {
      final top3 = [
        makeEntry(
          rank: 1,
          displayName: 'EndsWith SVG',
          level: 10,
          avatarUrl: 'https://cdn.example.com/avatar.svg',
        ),
        makeEntry(
          rank: 2,
          displayName: 'Path SVG',
          level: 8,
          avatarUrl: 'https://cdn.example.com/path/svg/avatar.png',
        ),
        makeEntry(
          rank: 3,
          displayName: 'Format SVG',
          level: 6,
          avatarUrl: 'https://cdn.example.com/avatar.png?format=svg',
        ),
      ];

      await tester.pumpWidget(wrap(PodiumTop3(top3: top3), dark: true));
      await tester.pumpAndSettle();

      expect(find.byType(PodiumTop3), findsOneWidget);
      expect(find.byType(SvgPicture), findsNWidgets(3));
    },
  );

  testWidgets(
    'PodiumTop3 (dark): non-svg avatar uses NetworkImage foregroundImage',
    (tester) async {
      final top3 = [
        makeEntry(
          rank: 1,
          displayName: 'PNG User',
          level: 10,
          avatarUrl: 'https://example.com/avatar.png',
        ),
        makeEntry(rank: 2, displayName: 'No Avatar 1', level: 5),
        makeEntry(rank: 3, displayName: 'No Avatar 2', level: 3, avatarUrl: ''),
      ];

      await tester.pumpWidget(wrap(PodiumTop3(top3: top3), dark: true));
      await tester.pumpAndSettle();

      final avatars = tester.widgetList<CircleAvatar>(
        find.byType(CircleAvatar),
      );

      final hasNetworkImage = avatars.any(
        (avatar) => avatar.foregroundImage is NetworkImage,
      );

      expect(hasNetworkImage, isTrue);
    },
  );
}
