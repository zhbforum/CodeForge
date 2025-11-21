import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/error/error_notifier.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final errorNotifier = ref.read(appErrorProvider.notifier);
  return ErrorHandler(showUiErrorCallback: errorNotifier.show);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final client = ref.read(supabaseClientProvider);
  final errorHandler = ref.read(errorHandlerProvider);

  return ApiService(client: client, errorHandler: errorHandler);
});
