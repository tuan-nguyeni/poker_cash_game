class Player {
  String name;
  int buyIns;
  int chips;

  Player({required this.name, this.buyIns = 0, this.chips = 0});

  int get profit => (chips - (buyIns * 1000)) ~/ 100;
}
