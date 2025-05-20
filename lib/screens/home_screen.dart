import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_screen.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    // Animation controller for fade + slide
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showLoading(String msg) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => FadeTransition(
        opacity: _fadeAnim,
        child: AlertDialog(
          backgroundColor: Colors.black87,
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createRoom() async {
    await _showLoading('Creating room… Please wait');
    final col = FirebaseFirestore.instance.collection('rooms');
    final doc = col.doc();
    final user = FirebaseAuth.instance.currentUser!;
    final myName = user.displayName ?? 'Player-${user.uid.substring(0, 5)}';
    await doc.set({
      'player1': myName,
      'player2': '',
      'board': List.filled(9, ''),
      'turn': 'X',
      'scores': {'X': 0, 'O': 0},
    });
    if (!mounted) return;
    Navigator.pop(context);
    _goToGame(doc.id);
  }

  Future<void> joinRoomDialog() async {
    final TextEditingController roomIdCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => FadeTransition(
        opacity: _fadeAnim,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enter Room ID'),
          content: TextField(
            controller: roomIdCtrl,
            decoration: const InputDecoration(
              hintText: 'Room ID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(roomIdCtrl.text.trim());
              },
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    ).then((roomId) {
      if (roomId != null && roomId.isNotEmpty) {
        joinRoom(roomId);
      }
    });
  }

  Future<void> joinRoom(String roomId) async {
    await _showLoading('Joining… Please wait');
    final docRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
    final snap = await docRef.get();
    if (snap.exists) {
      final data = snap.data()! as Map<String, dynamic>;
      final user = FirebaseAuth.instance.currentUser!;
      final myName = user.displayName ?? 'Player-${user.uid.substring(0, 5)}';
      if ((data['player2'] as String).isEmpty && data['player1'] != myName) {
        await docRef.update({'player2': myName});
        if (!mounted) return;
        Navigator.pop(context);
        _goToGame(roomId);
        return;
      }
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Room full or doesn't exist")),
    );
  }

  void _goToGame(String roomId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(roomId: roomId),
        transitionsBuilder: (_, a, __, c) => ScaleTransition(scale: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final myName = user.displayName ?? 'Player';

    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(gradient: appGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  'Welcome, $myName!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  AnimatedCard(
                    label: 'Create Room',
                    onTap: createRoom,
                  ),
                  const SizedBox(height: 24),
                  AnimatedCard(
                    label: 'Join Room',
                    onTap: joinRoomDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const AnimatedCard({required this.label, required this.onTap, super.key});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered
              ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          splashColor: Colors.white30,
          highlightColor: Colors.white10,
          child: SizedBox(
            height: 72,
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
