import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://jjbzmxbbgpocqjvyfdon.supabase.co',
      anonKey: _anonKey,
      // authFlowType: AuthFlowType.pkce,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

const _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpqYnpteGJiZ3BvY3FqdnlmZG9uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNTgxNzUsImV4cCI6MjA3MjkzNDE3NX0.bEg20r1B8I7WrL6iiC-p_e64Q-E9-4x91lEH7Rg6Yek';
