class Player {
  String name;
  int buyIns;
  int chips;
  int _mutableProfit;

  Player({required this.name, this.buyIns = 0, this.chips = 0})
      : _mutableProfit = 0;

  int get profit {
    if (_mutableProfit != 0) {
      return _mutableProfit;
    }
    return (chips - (buyIns * 1000)) ~/ 100;
  }

  set profit(int value) {
    _mutableProfit = value;
  }
}