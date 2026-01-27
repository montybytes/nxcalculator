class HistoryItem {
  final String result;
  final List<String> equation;

  HistoryItem({required this.result, required this.equation});

  bool equals(HistoryItem other) {
    if (result != other.result) {
      return false;
    }

    if (equation.length != other.equation.length) {
      return false;
    }

    for (var i = 0; i < equation.length; i++) {
      if (equation[i] != other.equation[i]) {
        return false;
      }
    }
    return true;
  }

  String serialize() {
    return "$result|${equation.join(",")}";
  }

  factory HistoryItem.fromData(String value) {
    final data = value.split("|");
    return HistoryItem(result: data[0], equation: data[1].split(","));
  }
}
