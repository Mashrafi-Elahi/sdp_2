import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme.dart';
import 'game_screen.dart';
import 'board_game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  /// true = opened from "Play as Guest" (no Firebase user).
  final bool isGuest;

  const MainMenuScreen({super.key, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;
    final userEmail = isGuest ? 'Guest' : (user?.email ?? 'Player');

    return Scaffold(
      backgroundColor: GHColors.bg,
      appBar: AppBar(
        title: const Text('Main Menu'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: GHColors.textMuted),
            tooltip: isGuest ? 'Back to login' : 'Sign out',
            onPressed: () async {
              if (isGuest) {
                // Guest was pushed on top of LoginScreen, so just go back.
                Navigator.pop(context);
              } else {
                try {
                  await GoogleSignIn().signOut();
                } catch (_) {}
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: GHColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: GHColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GHColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: GHColors.bg,
                        shape: BoxShape.circle,
                        border: Border.all(color: GHColors.border, width: 2),
                      ),
                      child: const Icon(Icons.person,
                          size: 40, color: GHColors.accent),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName != null && displayName.isNotEmpty
                          ? displayName
                          : userEmail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GHColors.textBright,
                      ),
                    ),
                    if (displayName != null && displayName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: GHColors.textMuted,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready to play?',
                      style: TextStyle(color: GHColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2 Player (Pass & Play) - Primary evaluation mode
              ElevatedButton.icon(
                onPressed: () => _startGame(context, players: 2, diceCount: 1),
                icon: const Icon(Icons.people),
                label: const Text('2 Player (Pass & Play)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),

              // Play vs Computer (AI Bot)
              OutlinedButton.icon(
                onPressed: () => _startGame(
                  context,
                  players: 2,
                  diceCount: 1,
                  isVsAi: true,
                ),
                icon: const Icon(Icons.smart_toy, color: GHColors.accent),
                label: const Text('Play vs Computer (Bot)',
                    style: TextStyle(color: GHColors.accent)),
                style: _outlinedStyle(),
              ),
              const SizedBox(height: 12),

              // 100-Tile Board Game (Snakes & Ladders style)
              OutlinedButton.icon(
                onPressed: () => _showBoardGameModeDialog(context),
                icon: const Icon(Icons.grid_on, color: Color(0xFFF0B429)),
                label: const Text('100-Tile Board Game (New ✨)',
                    style: TextStyle(color: Color(0xFFF0B429))),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  side: const BorderSide(color: Color(0xFFF0B429)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),

              // Custom: choose players and dice
              OutlinedButton.icon(
                onPressed: () => _showCustomGameDialog(context),
                icon: const Icon(Icons.tune, color: GHColors.accent),
                label: const Text('Custom Game',
                    style: TextStyle(color: GHColors.accent)),
                style: _outlinedStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _outlinedStyle() => OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(55),
        side: const BorderSide(color: GHColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );

  void _startGame(
    BuildContext context, {
    required int players,
    required int diceCount,
    bool isVsAi = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          playerCount: players,
          diceCount: diceCount,
          isVsAi: isVsAi,
        ),
      ),
    );
  }

  void _showBoardGameModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GHColors.card,
        title: const Text('100-Tile Board Game',
            style: TextStyle(color: GHColors.textBright)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Race to tile 100 with Portals 🚀 & Traps ⚠️!',
              style: TextStyle(color: GHColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('2 Player (Pass & Play)'),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const BoardGameScreen(isVsAi: false),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.smart_toy, color: GHColors.accent),
              label: const Text('Play vs Computer (Bot)',
                  style: TextStyle(color: GHColors.accent)),
              style: _outlinedStyle(),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const BoardGameScreen(isVsAi: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomGameDialog(BuildContext context) {
    int players = 2;
    int diceCount = 1;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setLocal) => AlertDialog(
          backgroundColor: GHColors.card,
          title: const Text('Custom Game',
              style: TextStyle(color: GHColors.textBright)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Players', style: TextStyle(color: GHColors.text)),
              SegmentedButton<int>(
                segments: [
                  for (var n = 2; n <= 4; n++)
                    ButtonSegment(value: n, label: Text('$n')),
                ],
                selected: {players},
                onSelectionChanged: (s) => setLocal(() => players = s.first),
              ),
              const SizedBox(height: 16),
              const Text('Dice per turn',
                  style: TextStyle(color: GHColors.text)),
              SegmentedButton<int>(
                segments: [
                  for (var n = 1; n <= 3; n++)
                    ButtonSegment(value: n, label: Text('$n')),
                ],
                selected: {diceCount},
                onSelectionChanged: (s) =>
                    setLocal(() => diceCount = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _startGame(context, players: players, diceCount: diceCount);
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}