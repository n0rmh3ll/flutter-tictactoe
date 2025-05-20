import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For Clipboard
import '../theme.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  const GameScreen({required this.roomId, super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late CollectionReference rooms;
  String mySymbol = '', oppName = '', myName = '';
  Map<String, dynamic>? roomData;

  bool hasUpdatedScore = false;

  @override
  void initState() {
    super.initState();
    rooms = FirebaseFirestore.instance.collection('rooms');
    myName = FirebaseAuth.instance.currentUser!.displayName!;
  }

  void _resetBoard() {
    hasUpdatedScore = false;
    final newStarter = roomData!['lastStarter'] == 'X' ? 'O' : 'X';
    rooms.doc(widget.roomId).update({
      'board': List.filled(9, ''),
      'turn': newStarter,
      'lastStarter': newStarter,
    });
  }

  String? _checkWinner(List board) {
    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];
    for (var w in wins) {
      final a = board[w[0]], b = board[w[1]], c = board[w[2]];
      if (a != '' && a == b && b == c) return a;
    }
    if (!board.contains('')) return 'Draw';
    return null;
  }

  Future<void> updateScore(String winner, Map<String, int> scores) async {
    if (hasUpdatedScore) return;
    hasUpdatedScore = true;

    if (winner != 'Draw') {
      scores[winner] = (scores[winner] ?? 0) + 1;
      await rooms.doc(widget.roomId).update({'scores': scores});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.roomId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Room ID copied to clipboard')),
            );
          },
          child: Text('Room: ${widget.roomId}'),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: rooms.doc(widget.roomId).snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          roomData = snap.data!.data() as Map<String, dynamic>;
          final b = List<String>.from(roomData!['board']);
          final turn = roomData!['turn'] as String;
          final scores = Map<String, int>.from(roomData!['scores']);
          if (roomData!['player1'] == myName) mySymbol = 'X';
          else if (roomData!['player2'] == myName) mySymbol = 'O';
          oppName = (mySymbol == 'X' ? roomData!['player2'] : roomData!['player1']) ?? '';
          final winner = _checkWinner(b);

          if (winner != null && !hasUpdatedScore) {
            updateScore(winner, scores);
            Future.delayed(const Duration(seconds: 2), () {
              _resetBoard();
            });
          }

          return Container(
            decoration: BoxDecoration(gradient: appGradient),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(roomData!['player1'], style: const TextStyle(fontSize: 16)),
                        Text('${scores['X']}', style: const TextStyle(fontSize: 24))
                      ],
                    ),
                    Column(
                      children: [
                        Text(roomData!['player2'], style: const TextStyle(fontSize: 16)),
                        Text('${scores['O']}', style: const TextStyle(fontSize: 24))
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, childAspectRatio: 1),
                    itemCount: 9,
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        onTap: () {
                          if (b[i] == '' && turn == mySymbol && winner == null) {
                            b[i] = mySymbol;
                            rooms.doc(widget.roomId).update({
                              'board': b,
                              'turn': mySymbol == 'X' ? 'O' : 'X',
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(b[i], style: const TextStyle(fontSize: 48)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                  child: Text(
                    winner == null
                        ? (turn == mySymbol ? 'Your Turn' : '$oppName\'s Turn')
                        : (winner == 'Draw'
                            ? 'Draw!'
                            : (winner == mySymbol ? 'You Win!' : 'You Lose!')),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _resetBoard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
