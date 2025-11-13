import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/core/services/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
