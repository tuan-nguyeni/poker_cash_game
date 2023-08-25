import 'package:flutter/material.dart';
import 'package:poker_cash_game/widgets.dart';

void main() => runApp(PokerSimulatorApp());

class PokerSimulatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Cash Game Simulator',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: PokerHomePage(),
    );
  }
}
