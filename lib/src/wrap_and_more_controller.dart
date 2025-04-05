import 'dart:math';
import 'package:flutter/material.dart';

/// Controller that handles the logic for calculating the number of child widgets to display,
/// checking for overflow, and notifying the UI to update.
class WrapAndMoreController extends ChangeNotifier {
  final int maxRow;
  final double spacing;
  final double runSpacing;
  final int childrenCount;

  /// Key to measure the initial Row
  final GlobalKey rowKey = GlobalKey();

  /// List of sizes for each child widget
  late List<Size> _childrenSizes;

  /// Size of the overflow widget
  Size _overflowSize = Size.zero;

  bool _isCounted = false;
  bool _isRendered = false;
  int _showChildCount = 0;
  double rowHeight = 0;
  double _maxWidth = 0;
  bool _hasOverflow = false;

  /// Whether the number of children has been calculated
  bool get isCounted => _isCounted;

  /// Whether the Row has been rendered for measurement
  bool get isRendered => _isRendered;

  /// Number of child widgets to display
  int get showChildCount => _showChildCount;

  /// Whether there is overflow (display the overflow widget)
  bool get hasOverflow => _hasOverflow;

  /// Maximum width of the Wrap
  double get maxWidth => _maxWidth;

  WrapAndMoreController({
    required this.maxRow,
    required this.spacing,
    required this.runSpacing,
    required this.childrenCount,
  }) {
    _childrenSizes = List.filled(childrenCount, Size.zero);
  }

  /// Update the size of each child widget after measurement
  void updateChildrenSize(int index, Size size) {
    _childrenSizes[index] = size;
    _calculateVisibleChildren();
  }

  /// Update the size of the overflow widget after measurement
  void updateOverflowSize(Size size) {
    _overflowSize = size;
    _calculateVisibleChildren();
  }

  /// Update the maximum width from the LayoutBuilder
  void updateMaxWidth(double maxWidth) {
    if (_maxWidth != maxWidth) {
      _maxWidth = maxWidth;
      _calculateVisibleChildren();
    }
  }

  /// Calculate the number of child widgets that can be displayed within maxRow,
  /// and check if the overflow widget needs to be displayed.
  void _calculateVisibleChildren() {
    // Wait until all child and overflow sizes are measured
    if (_maxWidth == 0 ||
        _childrenSizes.contains(Size.zero) ||
        _overflowSize == Size.zero) {
      return;
    }

    double currentRowWidth = 0;
    int currentRow = 1;
    int count = 0;
    double maxHeightPerRow = 0;
    _hasOverflow = false;

    for (var size in _childrenSizes) {
      if (currentRow > maxRow) break;

      // If the child widget exceeds the width, move to the next row
      if (currentRowWidth + size.width > _maxWidth) {
        currentRow++;
        if (currentRow > maxRow) break;
        currentRowWidth = 0;
      }

      currentRowWidth += size.width + spacing;
      maxHeightPerRow = max(maxHeightPerRow, size.height);
      count++;
    }

    // Check the overflow widget
    if (count < childrenCount) {
      if (currentRowWidth + _overflowSize.width > _maxWidth) {
        // If the overflow widget does not fit in the current row
        if (currentRow < maxRow) {
          currentRow++;
          if (currentRow <= maxRow) {
            currentRowWidth = _overflowSize.width + spacing;
          } else {
            count--; // Move back 1 child widget to make room for overflow
          }
        } else {
          count--;
        }
      } else {
        currentRowWidth += _overflowSize.width + spacing;
      }
      _hasOverflow = true;
    }

    rowHeight = maxHeightPerRow;
    _showChildCount = count;
    _isCounted = true;
    _isRendered = true;
    notifyListeners();
  }
}
