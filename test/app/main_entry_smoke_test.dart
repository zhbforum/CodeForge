import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart' as entry;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sf;

void main() {
  testWidgets('main() runs smoke', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await entry.main();

    sf.Supabase.instance.client.auth.stopAutoRefresh();

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 11));
    await tester.idle();
  });
}
