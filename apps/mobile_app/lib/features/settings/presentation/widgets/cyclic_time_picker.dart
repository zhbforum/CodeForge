import 'package:flutter/material.dart';

class CyclicTimePicker extends StatefulWidget {
  const CyclicTimePicker({
    required this.initialHour,
    required this.initialMinute,
    required this.onChanged,
    super.key,
  });

  final int initialHour;
  final int initialMinute;
  final void Function(int hour, int minute) onChanged;

  @override
  State<CyclicTimePicker> createState() => _CyclicTimePickerState();
}

class _CyclicTimePickerState extends State<CyclicTimePicker> {
  late FixedExtentScrollController _hCtrl;
  late FixedExtentScrollController _mCtrl;

  static const _loopSpan = 100000;
  static const _baseIndex = _loopSpan ~/ 2;

  @override
  void initState() {
    super.initState();
    _hCtrl = FixedExtentScrollController(
      initialItem: _baseIndex + widget.initialHour,
    );
    _mCtrl = FixedExtentScrollController(
      initialItem: _baseIndex + widget.initialMinute,
    );
  }

  int _mod(int i, int m) => (i % m + m) % m;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge;

    Widget wheel({
      required FixedExtentScrollController controller,
      required int modulus,
      required String Function(int) label,
    }) {
      return Expanded(
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 40,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.002,
          overAndUnderCenterOpacity: 0.4,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: _loopSpan,
            builder: (context, i) {
              if (i < 0 || i >= _loopSpan) return null;
              final v = _mod(i, modulus);
              return Center(child: Text(label(v), style: textStyle));
            },
          ),
          onSelectedItemChanged: (_) {
            widget.onChanged(
              _mod(_hCtrl.selectedItem, 24),
              _mod(_mCtrl.selectedItem, 60),
            );
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        wheel(
          controller: _hCtrl,
          modulus: 24,
          label: (v) => v.toString().padLeft(2, '0'),
        ),
        const SizedBox(width: 8),
        const Text(':'),
        const SizedBox(width: 8),
        wheel(
          controller: _mCtrl,
          modulus: 60,
          label: (v) => v.toString().padLeft(2, '0'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _mCtrl.dispose();
    super.dispose();
  }
}
