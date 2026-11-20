import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../theme.dart';
import '../widgets/dice_face.dart';

/// Turn-based "race to target" dice game.
///
/// The game is fully driven by two numbers:
///   * [playerCount] – how many players take turns (1 = solo mode)
///   * [diceCount]   – how many dice each player rolls per turn
///
/// So adding more players / dice is just: GameScreen(playerCount: 4, diceCount: 2)
class GameScreen extends StatefulWidget {
  final int playerCount;
  final int diceCount;
  final int targetScore;
  final bool isVsAi;

  const GameScreen({
    super.key,
    this.playerCount = 2,
    this.diceCount = 1,
    int? targetScore,
    this.isVsAi = false,
  }) : targetScore = targetScore ?? 30;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  /// Cryptographically secure random number generator using OS hardware entropy.
  final Random _random = Random.secure();

  // One entry per player instead of player1Score / player2Score variables.
  late List<int> scores;
  // dice[playerIndex][dieIndex] = face value shown for that player.
  late List<List<int>> dice;

  int currentPlayer = 0; // 0-based index
  int rollCount = 0;
  bool gameOver = false;
  bool _isRolling = false;

  late AnimationController _controller;
  Timer? _rollTimer;

  bool get isComputerTurn => widget.isVsAi && currentPlayer == 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _initState();
  }

  void _initState() {
    scores = List.filled(widget.playerCount, 0);
    dice = List.generate(
      widget.playerCount,
      (_) => List.filled(widget.diceCount, 1),
    );
    currentPlayer = 0;
    rollCount = 0;
    gameOver = false;
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Returns a list of [count] random dice values (1..6).
  List<int> _rollValues(int count) =>
      List.generate(count, (_) => _random.nextInt(6) + 1);

  String _getPlayerName(int index) {
    if (widget.isVsAi) {
      return index == 0 ? 'You' : 'Computer 🤖';
    }
    return 'Player ${index + 1}';
  }

  void _triggerAiTurnIfNeeded() {
    if (widget.isVsAi && currentPlayer == 1 && !gameOver && !_isRolling) {
      Timer(const Duration(milliseconds: 900), () {
        if (mounted && !gameOver && currentPlayer == 1 && !_isRolling) {
          rollDice();
        }
      });
    }
  }

  Future<void> rollDice() async {
    if (gameOver || _isRolling) return;

    setState(() {
      _isRolling = true;
      rollCount++;
    });
    _controller.forward(from: 0);

    // Shuffle faces quickly for the "rolling" effect.
    _rollTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted) {
        setState(() => dice[currentPlayer] = _rollValues(widget.diceCount));
      }
    });

    await Future.delayed(const Duration(milliseconds: 700));
    _rollTimer?.cancel();
    if (!mounted) return;

    final finalRoll = _rollValues(widget.diceCount);
    final total = finalRoll.reduce((a, b) => a + b);

    setState(() {
      dice[currentPlayer] = finalRoll;
      if (scores[currentPlayer] + total <= widget.targetScore) {
        scores[currentPlayer] += total;
      }
      _isRolling = false;

      if (scores[currentPlayer] >= widget.targetScore) {
        gameOver = true;
        final winnerTitle = widget.isVsAi
            ? (currentPlayer == 0 ? 'You Win! 🎉' : 'Computer Wins! 🤖')
            : 'Player ${currentPlayer + 1} Wins! 🏆';
        _showWinnerDialog(winnerTitle);
      } else {
        // Next player's turn (wraps around).
        currentPlayer = (currentPlayer + 1) % widget.playerCount;
      }
    });

    // If it's now computer's turn, trigger auto-roll.
    if (!gameOver) {
      _triggerAiTurnIfNeeded();
    }
  }

  void _showWinnerDialog(String winnerTitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: GHColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: GHColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events,
                    size: 60, color: Color(0xFFF0B429)),
                const SizedBox(height: 12),
                Text(
                  winnerTitle,
                  style: const TextStyle(
                    color: GHColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total rolls: $rollCount',
                  style: const TextStyle(color: GHColors.textMuted),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        resetGame();
                      },
                      child: const Text('Play Again'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Main Menu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void resetGame() => setState(_initState);

  @override
  Widget build(BuildContext context) {
    final title = widget.isVsAi
        ? 'You vs Computer 🤖'
        : '${widget.playerCount} Players • ${widget.diceCount} Dice';

    return Scaffold(
      backgroundColor: GHColors.bg,
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: GHColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _infoChip(
                Icons.emoji_events,
                'First to reach ${widget.targetScore} wins! (Rolls: $rollCount)',
              ),
              const SizedBox(height: 20),

              // Turn banner
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(currentPlayer),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isComputerTurn
                        ? GHColors.accent.withValues(alpha: 0.15)
                        : GHColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isComputerTurn
                          ? GHColors.accent
                          : GHColors.greenBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isComputerTurn ? Icons.smart_toy : Icons.play_arrow,
                        size: 18,
                        color: isComputerTurn ? GHColors.accent : GHColors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isComputerTurn
                            ? 'Computer\'s Turn...'
                            : (widget.isVsAi && currentPlayer == 0
                                ? 'Your Turn'
                                : '${_getPlayerName(currentPlayer)}\'s Turn'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isComputerTurn ? GHColors.accent : GHColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Player panels
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(
                  widget.playerCount,
                  (i) => _buildPlayerPanel(i),
                ),
              ),

              const SizedBox(height: 36),

              // Roll button
              ElevatedButton.icon(
                onPressed: (isComputerTurn || _isRolling || gameOver)
                    ? null
                    : rollDice,
                icon: Icon(
                  isComputerTurn ? Icons.smart_toy : Icons.casino,
                  size: 20,
                ),
                label: Text(
                  isComputerTurn
                      ? 'COMPUTER IS ROLLING...'
                      : (_isRolling ? 'ROLLING...' : 'ROLL DICE'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GHColors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: GHColors.border,
                  disabledForegroundColor: GHColors.textMuted,
                  minimumSize: const Size(260, 55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GHColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GHColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: GHColors.accent, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: GHColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerPanel(int index) {
    final isActive = index == currentPlayer;
    final isRollingNow = index == currentPlayer && _isRolling;
    final diceSize = widget.diceCount == 1 ? 70.0 : 44.0;
    final isBot = widget.isVsAi && index == 1;

    final panel = GestureDetector(
      onTap: () {
        if (index == currentPlayer && !isBot && !_isRolling && !gameOver) {
          rollDice();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 155,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: GHColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? GHColors.greenBorder : GHColors.border,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: GHColors.green.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getPlayerName(index),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? GHColors.green : GHColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GHColors.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GHColors.border),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: dice[index].map((value) {
                      return Transform.rotate(
                        angle: isRollingNow ? _controller.value * 6 * pi : 0,
                        child: DiceFace(
                          value: value,
                          size: diceSize,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? GHColors.green.withValues(alpha: 0.15)
                    : GHColors.bg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive ? GHColors.greenBorder : GHColors.border,
                ),
              ),
              child: Text(
                '${scores[index]} / ${widget.targetScore}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isActive ? GHColors.green : GHColors.text,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar towards target score
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (scores[index] / widget.targetScore).clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: GHColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isActive ? GHColors.green : GHColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (index == 1 && widget.playerCount == 2 && !widget.isVsAi) {
      return Transform.rotate(
        angle: pi,
        child: panel,
      );
    }
    return panel;
  }
}
