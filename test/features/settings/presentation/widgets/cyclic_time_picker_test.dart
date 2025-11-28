import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/settings/presentation/widgets/cyclic_time_picker.dart';

void main() {
  Widget buildPicker({
    required int hour,
    required int minute,
    required void Function(int, int) onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: CyclicTimePicker(
            initialHour: hour,
            initialMinute: minute,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('CyclicTimePicker builds wheels and separator', (tester) async {
    int? changedHour;
    int? changedMinute;

    await tester.pumpWidget(
      buildPicker(
        hour: 10,
        minute: 15,
        onChanged: (h, m) {
          changedHour = h;
          changedMinute = m;
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CyclicTimePicker), findsOneWidget);
    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    expect(find.text(':'), findsOneWidget);

    expect(changedHour, isNull);
    expect(changedMinute, isNull);
  });

  testWidgets('CyclicTimePicker calls onChanged when hour wheel scrolls', (
    tester,
  ) async {
    int? changedHour;
    int? changedMinute;

    await tester.pumpWidget(
      buildPicker(
        hour: 5,
        minute: 30,
        onChanged: (h, m) {
          changedHour = h;
          changedMinute = m;
        },
      ),
    );

    await tester.pumpAndSettle();

    final hourWheel = find.byType(ListWheelScrollView).at(0);
    await tester.drag(hourWheel, const Offset(0, -40));
    await tester.pumpAndSettle();

    expect(changedHour, isNotNull);
    expect(changedMinute, isNotNull);
  });

  testWidgets('CyclicTimePicker calls onChanged when minute wheel scrolls', (
    tester,
  ) async {
    int? changedHour;
    int? changedMinute;

    await tester.pumpWidget(
      buildPicker(
        hour: 12,
        minute: 0,
        onChanged: (h, m) {
          changedHour = h;
          changedMinute = m;
        },
      ),
    );

    await tester.pumpAndSettle();

    final minuteWheel = find.byType(ListWheelScrollView).at(1);
    await tester.drag(minuteWheel, const Offset(0, -40));
    await tester.pumpAndSettle();

    expect(changedHour, isNotNull);
    expect(changedMinute, isNotNull);
  });

  testWidgets('CyclicTimePicker disposes its controllers without crashing', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildPicker(hour: 8, minute: 45, onChanged: (_, __) {}),
    );

    await tester.pumpAndSettle();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();

    expect(find.byType(CyclicTimePicker), findsNothing);
  });
}
