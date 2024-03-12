import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:wrap_and_more/src/collection_extension.dart';

/// A controller class that manages the logic for the `WrapAndMore` widget.
/// The `WrapAndMoreController` extends GetX's GetxController to handle reactive state management.
class WrapAndMoreController extends ChangeNotifier {
  /// A flag to determine whether the count of children has been calculated.
  bool _isCounted = false;

  /// A flag to determine whether the widget has been rendered.
  bool _isRendered = false;

  /// The key associated with the row widget to measure its size.
  late GlobalKey _rowKey;

  /// The size of a single child widget in the `Wrap`.
  late Size _childSize;

  /// A list that stores the area (width * height) of each child widget in the `Wrap`.
  late List<double> _childrenArea;

  /// The total area of the `Wrap`.
  double _areaWrap = 0;

  /// The number of child widgets to display within the `Wrap`.
  int _showChildCount = 0;

  /// The maximum number of rows to show within the `Wrap`.
  int _maxRowChild = 0;

  /// The spacing between children in the `Wrap`.
  double _spacingChild = 0;

  /// The size of the overflow widget.
  late Size _overflowSize;

  bool get isCounted => _isCounted;

  bool get isRendered => _isRendered;

  GlobalKey get rowKey => _rowKey;

  int get showChildCount => _showChildCount;

  Size get overflowSize => _overflowSize;

  /// Initializes the controller with necessary data for calculation.
  /// This method should be called before using the controller.
  void initData({
    required List<Widget> children,
    required GlobalKey key,
    required int maxRow,
    required double spacing,
  }) {
    _rowKey = key;
    _maxRowChild = maxRow;
    _spacingChild = spacing;
    _childrenArea = List.generate(children.length, (index) => 0);
  }

  /// Retrieves the size and position of the row widget.
  /// This method is called when the widget is ready.
  void getSizeAndPosition() {
    _isRendered = false;
    _childSize = _rowKey.currentContext?.size ?? Size.zero;
    _isCounted = true;
    notifyListeners();
  }

  /// Updates the size of a child widget at a given index in the `Wrap`.
  void updateChildrenSize(int index, Size value) {
    _childrenArea.replace((value.width + _spacingChild) * value.height, index);
  }

  /// Updates the size of the overflow widget.
  void updateOverflowSize(Size value) {
    _overflowSize = value;
    notifyListeners();
  }

  /// Updates the total area of the `Wrap`.
  void updateWrapArea(Size size) {
    _areaWrap = size.width * size.height;
    _countChildWidgetShow();
    notifyListeners();
  }

  /// Calculates the number of child widgets to display within the `Wrap`.
  void _countChildWidgetShow() {
    final List<double> listOfTempArea =
    List.generate(_maxRowChild, (index) => _areaWrap / _maxRowChild);

    int indexOfTempArea = 0;
    int showAreaCount = 0;

    final List<double> listAreaOfLastChild = [];

    for (int i = 0; i < listOfTempArea.length; i++) {
      while (indexOfTempArea + 1 < _childrenArea.length) {
        listOfTempArea[i] = listOfTempArea[i] - _childrenArea[indexOfTempArea];
        if (i == listOfTempArea.length - 1) {
          listAreaOfLastChild.add(_childrenArea[indexOfTempArea]);
        }
        showAreaCount++;
        if (listOfTempArea[i] < _childrenArea[indexOfTempArea + 1] ||
            listOfTempArea.length == _childrenArea.length) {
          indexOfTempArea++;
          break;
        }
        indexOfTempArea++;
      }
    }

    final double lastRowArea =
        listAreaOfLastChild.sum + (_overflowSize.width * _overflowSize.height);

    if (lastRowArea >= listOfTempArea.last) {
      showAreaCount--;
    } else {
      showAreaCount++;
    }
    _showChildCount = showAreaCount;
    _isRendered = true;
    notifyListeners();
  }
}
