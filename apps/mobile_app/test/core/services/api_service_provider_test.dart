import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/error/error_handler.dart';

void main() {
  test('errorhandlerProvider provides ErrorHandler instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final errorHandler = container.read(errorHandlerProvider);

    expect(errorHandler, isA<ErrorHandler>());
  });
}
