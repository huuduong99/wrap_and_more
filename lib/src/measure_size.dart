import 'package:flutter/widgets.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends StatefulWidget {
  /// Widget to calculate it's size.
  final Widget child;

  /// [onChange] will be called when the [Size] changes.
  /// [onChange] will return the value ONLY once if it didn't change, and it will NOT return a value if it's equals to [Size.zero]
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    required this.child,
    required this.onChange,
    super.key,
  });

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? oldSize;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MeasureSize oldWidget) {
    if (oldWidget.child != widget.child) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    }
    super.didUpdateWidget(oldWidget);
  }

  void _notifySize() {
    if (!mounted) return;

    final renderBox = context.findRenderObject();
    if (renderBox is RenderBox && renderBox.hasSize) {
      final newSize = renderBox.size;
      if (oldSize == null || oldSize != newSize) {
        oldSize = newSize;
        widget.onChange(newSize);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
