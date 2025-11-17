import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/core/services/error_handler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeThrowingSupabaseClient extends Fake implements SupabaseClient {
  FakeThrowingSupabaseClient(this.error);

  final Exception error;

  @override
  SupabaseQueryBuilder from(String table) {
    throw error;
  }

  @override
  PostgrestFilterBuilder<T> rpc<T>(
    String fn, {
    dynamic get,
    Map<String, dynamic>? params,
  }) {
    throw error;
  }
}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class MockPostgrestTransformBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

class MockErrorHandler extends Mock implements ErrorHandler {}

void main() {
  late MockErrorHandler errorHandler;

  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    errorHandler = MockErrorHandler();
  });

  test('query applies ilike/inFilter and maps list result', () async {
    final rows = <PostgrestMap>[
      {'id': 1, 'name': 'Alex'},
      {'id': 2, 'name': 'Alexa'},
    ];

    final client = MockSupabaseClient();
    final queryBuilder = MockSupabaseQueryBuilder();
    final filterBuilder = MockPostgrestFilterBuilder<PostgrestList>();

    when(() => client.from('users')).thenAnswer((_) => queryBuilder);

    when(
      () => queryBuilder.select('id,name'),
    ).thenAnswer((_) => filterBuilder as PostgrestFilterBuilder<PostgrestList>);

    when(
      () => filterBuilder.ilike('name', '%Alex%'),
    ).thenAnswer((_) => filterBuilder);

    when(
      () => filterBuilder.inFilter('ids', [1, 2]),
    ).thenAnswer((_) => filterBuilder);

    when(() => filterBuilder.eq(any(), any())).thenAnswer((_) => filterBuilder);

    when(
      () => filterBuilder.order('name', ascending: true),
    ).thenAnswer((_) => filterBuilder);

    when(() => filterBuilder.limit(10)).thenAnswer((_) => filterBuilder);

    when(
      () => filterBuilder.then<dynamic>(any(), onError: any(named: 'onError')),
    ).thenAnswer((invocation) {
      final onValue =
          invocation.positionalArguments[0]
              as FutureOr<dynamic> Function(PostgrestList);

      final value = onValue(rows);
      if (value is Future) {
        return value;
      }
      return Future.value(value);
    });

    final apiService = ApiService(client: client, errorHandler: errorHandler);

    final result = await apiService.query(
      table: 'users',
      select: 'id,name',
      filters: {
        'name': 'like:Alex',
        'ids': [1, 2],
      },
      orderBy: 'name',
      limit: 10,
    );

    expect(result, [
      {'id': 1, 'name': 'Alex'},
      {'id': 2, 'name': 'Alexa'},
    ]);

    verifyNever(() => errorHandler.handle(any(), any()));
  });

  test('single maps result to Map<String, dynamic>', () async {
    final row = <String, dynamic>{'id': 42, 'username': 'tester'};

    final client = MockSupabaseClient();
    final queryBuilder = MockSupabaseQueryBuilder();
    final filterBuilder = MockPostgrestFilterBuilder<PostgrestList>();
    final singleBuilder = MockPostgrestTransformBuilder<PostgrestMap>();

    when(() => client.from('profiles')).thenAnswer((_) => queryBuilder);

    when(
      () => queryBuilder.select('id,username'),
    ).thenAnswer((_) => filterBuilder as PostgrestFilterBuilder<PostgrestList>);

    when(() => filterBuilder.eq('id', 42)).thenAnswer((_) => filterBuilder);

    when(filterBuilder.single).thenAnswer((_) => singleBuilder);

    when(
      () => singleBuilder.then<dynamic>(any(), onError: any(named: 'onError')),
    ).thenAnswer((invocation) {
      final onValue =
          invocation.positionalArguments[0]
              as FutureOr<dynamic> Function(PostgrestMap);

      final value = onValue(row);
      if (value is Future) {
        return value;
      }
      return Future.value(value);
    });

    final apiService = ApiService(client: client, errorHandler: errorHandler);

    final result = await apiService.single(
      table: 'profiles',
      select: 'id,username',
      idField: 'id',
      id: 42,
    );

    expect(result, {'id': 42, 'username': 'tester'});
    verifyNever(() => errorHandler.handle(any(), any()));
  });

  test('query calls errorHandler and rethrows on failure', () async {
    final exception = Exception('query failed');
    final client = FakeThrowingSupabaseClient(exception);

    final apiService = ApiService(client: client, errorHandler: errorHandler);

    await expectLater(
      () => apiService.query(
        table: 'users',
        select: 'id,name',
        filters: {'name': 'like:Alex'},
        orderBy: 'name',
        limit: 10,
      ),
      throwsA(exception),
    );

    verify(() => errorHandler.handle(exception, any())).called(1);
  });

  test('single calls errorHandler and rethrows on failure', () async {
    final exception = Exception('single failed');
    final client = FakeThrowingSupabaseClient(exception);

    final apiService = ApiService(client: client, errorHandler: errorHandler);

    await expectLater(
      () => apiService.single(
        table: 'profiles',
        select: 'id,username',
        idField: 'id',
        id: 42,
      ),
      throwsA(exception),
    );

    verify(() => errorHandler.handle(exception, any())).called(1);
  });

  test('upsert calls errorHandler and rethrows on failure', () async {
    final exception = Exception('upsert failed');
    final client = FakeThrowingSupabaseClient(exception);

    final apiService = ApiService(client: client, errorHandler: errorHandler);

    await expectLater(
      () => apiService.upsert(
        table: 'courses',
        values: {'id': 1},
        onConflict: 'id',
      ),
      throwsA(exception),
    );

    verify(() => errorHandler.handle(exception, any())).called(1);
  });

  test('delete calls errorHandler and rethrows on failure', () async {
    final exception = Exception('delete failed');
    final client = FakeThrowingSupabaseClient(exception);

    final apiService = ApiService(client: client, errorHandler: errorHandler);

    await expectLater(
      () => apiService.delete(table: 'tracks', field: 'id', value: 10),
      throwsA(exception),
    );

    verify(() => errorHandler.handle(exception, any())).called(1);
  });

  test('rpc calls errorHandler and rethrows on failure', () async {
    final exception = Exception('rpc failed');
    final client = FakeThrowingSupabaseClient(exception);

    final apiService = ApiService(client: client, errorHandler: errorHandler);

    await expectLater(
      () => apiService.rpc<int>('add', params: {'a': 1, 'b': 2}),
      throwsA(exception),
    );

    verify(() => errorHandler.handle(exception, any())).called(1);
  });
}
