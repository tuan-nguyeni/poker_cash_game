import 'package:flutter/material.dart';

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


class PokerHomePage extends StatefulWidget {
  @override
  _PokerHomePageState createState() => _PokerHomePageState();
}

class _PokerHomePageState extends State<PokerHomePage> {
  List<Player> players = [];
  String gameResults = "";
  String transactions = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poker Cash Game Calculator'),
        actions: [
          Tooltip(
            message: 'User Manual',
            child: IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: _showUserManual,
            ),
          ),
          Tooltip(
            message: 'End Game and Calculate Results',
            child: IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: _endGame,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return ListTile(
                  title: Text(player.name),
                  subtitle: Text('Buy ins: ${player.buyIns}, Chips: ${player.chips}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Add a Buy-In',
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _addBuyIn(index),
                        ),
                      ),
                      Tooltip(
                        message: 'Remove a Buy-In',
                        child: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => _removeBuyIn(index),
                        ),
                      ),
                      Tooltip(
                        message: 'Set Chip Count',
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _setChips(index),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: gameResults),
              readOnly: true,
              maxLines: null,
              decoration: InputDecoration(
                labelText: "Game Results",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: transactions),
              readOnly: true,
              maxLines: null,
              decoration: InputDecoration(
                labelText: "Transactions",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Tooltip(
        message: 'Add a New Player',
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _addPlayer,
        ),
      ),
    );
  }

  void _addPlayer() async {
    final playerName = await _showInputDialog('Enter Player Name');
    if (playerName != null && playerName.isNotEmpty) {
      setState(() {
        players.add(Player(name: playerName));
      });
    }
  }

  void _addBuyIn(int index) {
    setState(() {
      players[index].buyIns++;
    });
  }

  void _removeBuyIn(int index) {
    setState(() {
      if (players[index].buyIns > 0) players[index].buyIns--;
    });
  }

  void _setChips(int index) async {
    final chipCount = await _showInputDialog('Enter Chip Count');
    if (chipCount != null && chipCount.isNotEmpty) {
      setState(() {
        players[index].chips = int.tryParse(chipCount) ?? players[index].chips;
      });
    }
  }

  void _endGame() {
    int totalProfit = players.fold(0, (sum, player) => sum + player.profit);

    if (totalProfit != 0) {
      _showErrorDialog(totalProfit);
    } else {
      _calculateTransactions();
      setState(() {
        gameResults = players.map((player) => "${player.name}: Profit: ${player.profit}€").join('\n');
      });
    }
  }

  void _calculateTransactions() {
    List<Player> owedMoney = players.where((p) => p.profit > 0).toList();
    List<Player> oweMoney = players.where((p) => p.profit < 0).toList();

    owedMoney.sort((a, b) => b.profit.compareTo(a.profit));
    oweMoney.sort((a, b) => a.profit.compareTo(b.profit));

    List<String> transactionsList = [];

    while (owedMoney.isNotEmpty && oweMoney.isNotEmpty) {
      Player owed = owedMoney.first;
      Player owe = oweMoney.first;

      if (owed.profit.abs() > owe.profit.abs()) {
        transactionsList.add('${owe.name} owes ${owed.name} ${owe.profit.abs()}€');
        owed.profit += owe.profit;
        owe.profit = 0;
        oweMoney.removeAt(0);
      } else if (owed.profit.abs() < owe.profit.abs()) {
        transactionsList.add('${owe.name} owes ${owed.name} ${owed.profit.abs()}€');
        owe.profit += owed.profit;
        owed.profit = 0;
        owedMoney.removeAt(0);
      } else {
        transactionsList.add('${owe.name} owes ${owed.name} ${owed.profit.abs()}€');
        owed.profit = 0;
        owe.profit = 0;
        owedMoney.removeAt(0);
        oweMoney.removeAt(0);
      }
    }

    transactions = transactionsList.join('\n');
  }


  void _showErrorDialog(int discrepancy) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
              discrepancy > 0
                  ? 'There are ${discrepancy * 100} chips too many.'
                  : 'There are ${-discrepancy * 100} chips missing.'
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showInputDialog(String title) async {
    String? input;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            onChanged: (value) => input = value,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(input),
            ),
          ],
        );
      },
    );
  }

  void _showUserManual() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User Manual'),
          content: SingleChildScrollView(
            child: Text(
              'Welcome to the Poker Simulator!\n\n'
                  'Imagine you and your friends are playing a fun game with colorful chips. Here’s how it works:\n'
                  '1. Everyone starts by buying some chips. This is called a "buy-in".\n'
                  '2. Each buy-in gives you 1000 chips and costs 10€.\n'
                  '3. You can buy-in as many times as you want during the game.\n'
                  '4. At the end, we count how many chips everyone has and how many times they bought in.\n'
                  '5. Using this info, we figure out if you made a profit (earned more than you spent) or a loss.\n'
                  '6. Finally, we help you see who owes money to whom, so everything is fair!\n\n'
                  'For example, if you bought in once (so you spent 10€) but ended up with chips worth 20€, you made a profit of 10€!\n\n'
                  'How to use this app:\n'
                  '1. Click the "+" button to add a player.\n'
                  '2. For each player, you can:\n'
                  '   - Use the "+" button to add a buy-in.\n'
                  '   - Use the "-" button to remove a buy-in.\n'
                  '   - Use the "edit" button to set the number of chips.\n'
                  '3. Click the "play" button to end the game and see the results.\n\n'
                  'Happy playing!',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Got it!'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

}
