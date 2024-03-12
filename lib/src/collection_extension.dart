extension CollectionExtensions on List {
  void replace(item, int index) {
    if (index < length) {
      insert(index, item);
      removeAt(indexOf(item) + 1);
    } else {
      throw ('Index Out Of Bounds');
    }
  }
}