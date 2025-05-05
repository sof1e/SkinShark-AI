extension ListReshape<T> on List<T> {
  List<List<T>> reshape(List<int> dims) {
    if (dims.length != 2) throw Exception('Reshape поддерживает только 2D');

    int rows = dims[0];
    int cols = dims[1];

    if (this.length != rows * cols)
      throw Exception('Неверный размер для reshape');

    List<List<T>> result = [];
    for (int i = 0; i < rows; i++) {
      result.add(this.sublist(i * cols, (i + 1) * cols));
    }
    return result;
  }
}
