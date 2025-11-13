import 'package:mobile_app/core/services/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  ApiService({SupabaseClient? client, ErrorHandler? errorHandler})
    : _client = client ?? Supabase.instance.client,
      _errorHandler = errorHandler ?? ErrorHandler();

  final SupabaseClient _client;
  final ErrorHandler _errorHandler;

  Future<List<Map<String, dynamic>>> query({
    required String table,
    required String select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      var filterBuilder = _client.from(table).select(select);

      if (filters != null) {
        for (final entry in filters.entries) {
          final key = entry.key;
          final value = entry.value;

          if (value is String && value.startsWith('like:')) {
            filterBuilder = filterBuilder.ilike(key, '%${value.substring(5)}%');
          } else if (value is List) {
            filterBuilder = filterBuilder.inFilter(key, value);
          } else {
            filterBuilder = filterBuilder.eq(key, value as Object);
          }
        }
      }

      var transformBuilder =
          filterBuilder as PostgrestTransformBuilder<List<dynamic>>;

      if (orderBy != null) {
        transformBuilder = transformBuilder.order(
          orderBy,
          ascending: ascending,
        );
      }
      if (limit != null) {
        transformBuilder = transformBuilder.limit(limit);
      }

      final result = await transformBuilder;
      return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> single({
    required String table,
    required String select,
    required String idField,
    required Object id,
  }) async {
    try {
      final result = await _client
          .from(table)
          .select(select)
          .eq(idField, id)
          .single();
      return Map<String, dynamic>.from(result as Map);
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<void> upsert({
    required String table,
    required Map<String, dynamic> values,
    String? onConflict,
  }) async {
    try {
      await _client.from(table).upsert(values, onConflict: onConflict);
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<void> delete({
    required String table,
    required String field,
    required Object value,
  }) async {
    try {
      await _client.from(table).delete().eq(field, value);
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<T?> rpc<T>(String fn, {Map<String, dynamic>? params}) async {
    try {
      final result = await _client.rpc<T>(fn, params: params);
      return result;
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }
}
