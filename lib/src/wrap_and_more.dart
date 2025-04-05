part of wrap_and_more;

/// A custom widget that extends Flutter's StatelessWidget and provides
/// a wrapped layout with an option to show an "overflow" widget when the
/// number of children exceeds a certain limit (maxRow).
///
/// The `WrapAndMore` widget lays out its children in a Wrap widget and
/// displays the specified `overflowWidget` when the children exceed the
/// maximum number of rows specified by the `maxRow` parameter. The number
/// of children to display is automatically determined based on the available
/// space within the Wrap.
///
/// The `overflowWidget` parameter is a function that takes an integer as input,
/// representing the number of remaining children beyond the `maxRow`, and
/// returns a widget to display as the "overflow" representation.
///
/// The `spacing` and `runSpacing` parameters control the spacing between
/// children in the Wrap.
///
/// The `children` parameter is a list of widgets to display within the Wrap.
///
/// Example Usage:
///
/// ```dart
/// WrapAndMore(
///   maxRow: 2,
///   spacing: 8.0,
///   runSpacing: 8.0,
///   overflowWidget: (restChildrenCount) {
///     return Text(
///       '+ $restChildrenCount more',
///       style: TextStyle(color: Colors.grey),
///     );
///   },
///   children: [
///     // Add your widgets here
///   ],
/// )
/// ```
class WrapAndMore extends StatefulWidget {
  const WrapAndMore({
    required this.maxRow,
    required this.overflowWidget,
    required this.children,
    this.spacing = 4.0,
    this.runSpacing = 4.0,
    this.alignment = WrapAlignment.end,
    super.key,
  });

  /// The list of child widgets to display in the Wrap.
  final List<Widget> children;

  /// The maximum number of rows to display in the Wrap.
  final int maxRow;

  /// The spacing between child widgets in the Wrap.
  final double spacing;

  /// The spacing between rows in the Wrap.
  final double runSpacing;

  /// Widget to display when the number of children exceeds the limit
  final Widget Function(int restChildrenCount) overflowWidget;

  /// Alignment of child widgets within each row
  final WrapAlignment alignment;

  @override
  State<WrapAndMore> createState() => _WrapAndMoreState();
}

class _WrapAndMoreState extends State<WrapAndMore> {
  late WrapAndMoreController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  /// Check and update the controller when the widget changes
  @override
  void didUpdateWidget(covariant WrapAndMore oldWidget) {
    if (widget.maxRow != oldWidget.maxRow ||
        widget.spacing != oldWidget.spacing ||
        widget.runSpacing != oldWidget.runSpacing ||
        widget.children.length != oldWidget.children.length) {
      _initController();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Initialize the controller
  void _initController() {
    _controller = WrapAndMoreController(
      maxRow: widget.maxRow,
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      childrenCount: widget.children.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update the maximum width
        _controller.updateMaxWidth(constraints.maxWidth);
        return ChangeNotifierProvider<WrapAndMoreController>.value(
          value: _controller,
          child: Consumer<WrapAndMoreController>(
            builder: (context, controller, child) {
              // When the number of children to display has been calculated
              if (controller.isCounted) {
                return SizedBox(
                  width: constraints.maxWidth,
                  child: Wrap(
                    spacing: widget.spacing,
                    runSpacing: widget.runSpacing,
                    alignment: widget.alignment,
                    children: [
                      // Display the children that fit within maxRow
                      ...widget.children.take(controller.showChildCount),
                      // Display the overflow widget if there is overflow
                      if (controller.hasOverflow)
                        widget.overflowWidget(
                          widget.children.length - controller.showChildCount,
                        ),
                    ],
                  ),
                );
              } else {
                // Measure the size of the child widgets and the overflow widget
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    key: controller.rowKey,
                    children: [
                      ...List.generate(widget.children.length, (index) {
                        return MeasureSize(
                          onChange: (Size size) {
                            controller.updateChildrenSize(index, size);
                          },
                          child: widget.children[index],
                        );
                      }),
                      MeasureSize(
                        child: widget.overflowWidget(0),
                        onChange: (size) {
                          controller.updateOverflowSize(size);
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
