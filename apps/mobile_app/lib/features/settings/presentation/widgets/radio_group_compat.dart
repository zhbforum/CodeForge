import 'package:flutter/material.dart';

class RadioOption<T> {
  const RadioOption(this.value, this.label);
  final T value;
  final String label;
}

class RadioGroupCompat<T> extends StatelessWidget {
  const RadioGroupCompat({
    required this.groupValue,
    required this.onChanged,
    required this.options,
    super.key,
  });

  final T groupValue;
  final void Function(T value) onChanged;
  final List<RadioOption<T>> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((o) {
        return RadioListTile<T>(
          title: Text(o.label),
          value: o.value,
          // ignore: deprecated_member_use
          groupValue: groupValue,
          // ignore: deprecated_member_use
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        );
      }).toList(),
    );
  }
}
