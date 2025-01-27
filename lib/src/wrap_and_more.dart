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
  /// The maximum number of rows to show within the Wrap.
  final int maxRow;

  /// The spacing between children in the Wrap.
  final double spacing;

  /// The run spacing between rows of children in the Wrap.
  final double runSpacing;

  /// A function that takes the number of remaining children beyond `maxRow`
  /// as input and returns a widget to represent the "overflow" children.
  final Widget Function(int restChildrenCount) overflowWidget;

  /// The list of widgets to display within the Wrap.
  final List<Widget> children;

  /// How the children within a run should be placed in the main axis.
  ///
  /// For example, if [alignment] is [WrapAlignment.center], the children in
  /// each run are grouped together in the center of their run in the main axis.
  ///
  /// Defaults to [WrapAlignment.start].
  ///
  /// See also:
  ///
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  final WrapAlignment alignment;

  /// Creates a WrapAndMore widget.
  ///
  /// The `maxRow` parameter specifies the maximum number of rows to display
  /// in the Wrap. The `spacing` and `runSpacing` parameters control the
  /// spacing between children in the Wrap.
  ///
  /// The `overflowWidget` parameter is a function that takes an integer as
  /// input, representing the number of remaining children beyond the `maxRow`,
  /// and returns a widget to display as the "overflow" representation.
  ///
  /// The `children` parameter is a list of widgets to display within the Wrap.
  const WrapAndMore({
    Key? key,
    required this.maxRow,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    required this.overflowWidget,
    required this.children,
    this.alignment = WrapAlignment.end,
  }) : super(key: key);

  @override
  State<WrapAndMore> createState() => _WrapAndMoreState();
}

class _WrapAndMoreState extends State<WrapAndMore> {
  late WrapAndMoreController _controller;
  final GlobalKey _rowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = WrapAndMoreController();
    _controller.initData(
      children: widget.children,
      maxRow: widget.maxRow,
      spacing: widget.spacing,
      key: _rowKey,
    );
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _controller.getSizeAndPosition(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WrapAndMoreController>.value(
      value: _controller,
      child: Builder(
        builder: (context) {
          final controller = context.watch<WrapAndMoreController>();
          if (controller.isCounted) {
            return MeasureSize(
              onChange: (size) {
                controller.updateWrapArea(size);
                widget.overflowWidget(controller.showChildCount);
              },
              child: SizedBox(
                height: (controller.overflowSize.height * widget.maxRow) +
                    (widget.runSpacing * (widget.maxRow - 1)),
                child: Wrap(
                  spacing: widget.spacing,
                  runSpacing: widget.runSpacing,
                  alignment: widget.alignment,
                  children: controller.isRendered
                      ? [
                    ...widget.children.take(controller.showChildCount),
                    if (widget.children.length -
                        controller.showChildCount >
                        0)
                      widget.overflowWidget(
                        widget.children.length -
                            controller.showChildCount,
                      ),
                  ]
                      : widget.children.toList(),
                ),
              ),
            );
          } else {
            return SizedBox(
              width: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  key: controller.rowKey,
                  children: [
                    ...widget.children.asMap().map((index, Widget value) {
                      return MapEntry(
                        index,
                        MeasureSize(
                          onChange: (Size size) {
                            controller.updateChildrenSize(index, size);
                          },
                          child: value,
                        ),
                      );
                    }).values,
                    MeasureSize(
                      child: widget.overflowWidget(0),
                      onChange: (p0) {
                        controller.updateOverflowSize(p0);
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
