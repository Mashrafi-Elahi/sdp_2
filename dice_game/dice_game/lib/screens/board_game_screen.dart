import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/dice_face.dart';

/// 100-Tile Visual Board Game (Snakes & Ladders style)
///
/// Features:
///   * True hardware randomness using [Random.secure()]
///   * 10x10 Serpentine Board (tiles 1 to 100)
///   * Custom shortcuts: Boost Portals 🚀 and Trap Hazards ⚠️
///   * 2 Player (Pass & Play) or Play vs Computer (Bot)
///   * Real-time token placement directly on board tiles
class BoardGameScreen extends StatefulWidget {
  final bool isVsAi;

  const BoardGameScreen({super.key, this.isVsAi = false});

  @override
  State<BoardGameScreen> createState() => _BoardGameScreenState();
}

class _BoardGameScreenState extends State<BoardGameScreen>
    with SingleTickerProviderStateMixin {
  /// Cryptographically secure random number generator using OS hardware entropy.
  final Random _random = Random.secure();

  // Positions on the board (1 to 100, 0 = Start)
  List<int> positions = [0, 0];
  int currentPlayer = 0; // 0 or 1
  int lastRoll = 1;
  int rollCount = 0;
  bool gameOver = false;
  bool _isRolling = false;
  String statusMessage = 'Tap "Roll Dice" to start!';

  late AnimationController _controller;
  Timer? _rollTimer;

  // Custom paths: Boosts (Ladders / Portals)
  static const Map<int, int> boosts = {
    4: 14,
    9: 31,
    20: 38,
    28: 84,
    40: 59,
    51: 67,
    63: 81,
    71: 91,
  };

  // Custom paths: Traps (Snakes / Hazards)
  static const Map<int, int> traps = {
    17: 7,
    54: 34,
    62: 19,
    64: 60,
    87: 24,
    93: 73,
    95: 75,
    99: 78,
  };

  bool get isComputerTurn => widget.isVsAi && currentPlayer == 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      positions = [0, 0];
      currentPlayer = 0;
      lastRoll = 1;
      rollCount = 0;
      gameOver = false;
      _isRolling = false;
      statusMessage = 'Game reset! Tap "Roll Dice" to start.';
    });
  }

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

    // Shuffle die face quickly for rolling effect
    _rollTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted) {
        setState(() => lastRoll = _random.nextInt(6) + 1);
      }
    });

    await Future.delayed(const Duration(milliseconds: 700));
    _rollTimer?.cancel();
    if (!mounted) return;

    // True cryptographic hardware random roll
    final rolled = _random.nextInt(6) + 1;
    final pName = _getPlayerName(currentPlayer);
    int newPos = positions[currentPlayer] + rolled;
    String eventNote = '';

    // Check if overshot tile 100 or hit 100
    if (newPos >= 100) {
      newPos = 100;
      eventNote = ' reached the goal!';
    } else if (boosts.containsKey(newPos)) {
      final dest = boosts[newPos]!;
      eventNote = ' hit a Portal 🚀! ($newPos ➔ $dest)';
      newPos = dest;
    } else if (traps.containsKey(newPos)) {
      final dest = traps[newPos]!;
      eventNote = ' hit a Trap ⚠️! ($newPos ➔ $dest)';
      newPos = dest;
    } else {
      eventNote = ' moved to tile $newPos.';
    }

    setState(() {
      lastRoll = rolled;
      positions[currentPlayer] = newPos;
      statusMessage = '$pName rolled a $rolled 🎲 and$eventNote';
      _isRolling = false;

      if (newPos >= 100) {
        gameOver = true;
        final winnerTitle = widget.isVsAi
            ? (currentPlayer == 0 ? 'You Win! 🎉' : 'Computer Wins! 🤖')
            : 'Player ${currentPlayer + 1} Wins! 🏆';
        _showWinnerDialog(winnerTitle);
      } else {
        currentPlayer = (currentPlayer + 1) % 2;
      }
    });

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
                  'Reached Tile 100 in $rollCount total rolls!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GHColors.textMuted),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetGame();
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

  /// Converts tile number (1 to 100) to grid coordinates (0 to 9, 0 to 9)
  /// Row 9 is bottom row, Row 0 is top row. Serpentine / boustrophedon.
  int _tileNumberAt(int gridRow, int gridCol) {
    final rowFromBottom = 9 - gridRow;
    if (rowFromBottom % 2 == 0) {
      // Left-to-right (tiles 1..10, 21..30, etc.)
      return rowFromBottom * 10 + gridCol + 1;
    } else {
      // Right-to-left (tiles 11..20, 31..40, etc.)
      return rowFromBottom * 10 + (9 - gridCol) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isVsAi ? '100-Tile vs Computer 🤖' : '100-Tile Board Game';

    return Scaffold(
      backgroundColor: GHColors.bg,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: GHColors.textMuted),
            tooltip: 'Restart',
            onPressed: _resetGame,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: GHColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              // Player scores / positions header
              Row(
                children: [
                  Expanded(
                    child: _playerScoreHeader(
                      index: 0,
                      name: widget.isVsAi ? 'You' : 'Player 1',
                      color: GHColors.green,
                      isActive: currentPlayer == 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _playerScoreHeader(
                      index: 1,
                      name: widget.isVsAi ? 'Computer 🤖' : 'Player 2',
                      color: const Color(0xFF58A6FF), // Cyan/Blue
                      isActive: currentPlayer == 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Status Banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: GHColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GHColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      isComputerTurn ? Icons.smart_toy : Icons.info_outline,
                      size: 16,
                      color: isComputerTurn ? GHColors.accent : GHColors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GHColors.text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // The 100-Tile Grid Board
              _buildBoard(),
              const SizedBox(height: 12),

              // Legend
              Wrap(
                spacing: 14,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: const [
                  _LegendChip(
                    icon: Icons.rocket_launch,
                    color: GHColors.green,
                    label: 'Portal 🚀 (+)',
                  ),
                  _LegendChip(
                    icon: Icons.warning_amber_rounded,
                    color: Color(0xFFF85149),
                    label: 'Trap ⚠️ (-)',
                  ),
                  _LegendChip(
                    icon: Icons.emoji_events,
                    color: Color(0xFFF0B429),
                    label: 'Tile 100 (Goal)',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Dice & Roll Button Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Die
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: GHColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GHColors.border),
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _isRolling ? _controller.value * 6 * pi : 0,
                          child: DiceFace(
                            value: lastRoll,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Roll Button
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
                          ? 'COMPUTER ROLLING...'
                          : (_isRolling ? 'ROLLING...' : 'ROLL DICE'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GHColors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: GHColors.border,
                      disabledForegroundColor: GHColors.textMuted,
                      minimumSize: const Size(190, 52),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playerScoreHeader({
    required int index,
    required String name,
    required Color color,
    required bool isActive,
  }) {
    final pos = positions[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GHColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color : GHColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              widget.isVsAi && index == 1 ? '🤖' : 'P${index + 1}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : GHColors.textMuted,
                  ),
                ),
                Text(
                  'Tile: $pos / 100',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: GHColors.textBright,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: GHColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GHColors.border),
      ),
      child: AspectRatio(
        aspectRatio: 1.0, // Square 10x10 board
        child: Column(
          children: List.generate(10, (row) {
            return Expanded(
              child: Row(
                children: List.generate(10, (col) {
                  final tileNum = _tileNumberAt(row, col);
                  return Expanded(
                    child: _buildTile(tileNum),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTile(int tileNum) {
    final isBoost = boosts.containsKey(tileNum);
    final isTrap = traps.containsKey(tileNum);
    final isGoal = tileNum == 100;

    final hasP1 = positions[0] == tileNum;
    final hasP2 = positions[1] == tileNum;

    Color tileBg;
    if (isGoal) {
      tileBg = const Color(0xFFF0B429).withValues(alpha: 0.25);
    } else if (isBoost) {
      tileBg = GHColors.green.withValues(alpha: 0.2);
    } else if (isTrap) {
      tileBg = const Color(0xFFF85149).withValues(alpha: 0.2);
    } else if (tileNum % 2 == 0) {
      tileBg = GHColors.bg;
    } else {
      tileBg = GHColors.card;
    }

    return Container(
      margin: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isGoal
              ? const Color(0xFFF0B429)
              : (isBoost
                  ? GHColors.greenBorder
                  : (isTrap ? const Color(0xFFF85149) : GHColors.border)),
          width: (isBoost || isTrap || isGoal) ? 1.0 : 0.4,
        ),
      ),
      child: Stack(
        children: [
          // Tile number
          Positioned(
            top: 1,
            left: 2,
            child: Text(
              '$tileNum',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isGoal
                    ? const Color(0xFFF0B429)
                    : (isBoost
                        ? GHColors.green
                        : (isTrap ? const Color(0xFFF85149) : GHColors.textMuted)),
              ),
            ),
          ),

          // Portal / Trap icon badge
          if (isBoost)
            const Positioned(
              bottom: 1,
              right: 1,
              child: Text('🚀', style: TextStyle(fontSize: 7)),
            )
          else if (isTrap)
            const Positioned(
              bottom: 1,
              right: 1,
              child: Text('⚠️', style: TextStyle(fontSize: 7)),
            )
          else if (isGoal)
            const Positioned(
              bottom: 1,
              right: 1,
              child: Text('👑', style: TextStyle(fontSize: 8)),
            ),

          // Player Tokens
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasP1)
                  Container(
                    width: 11,
                    height: 11,
                    decoration: const BoxDecoration(
                      color: GHColors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GHColors.green,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (hasP1 && hasP2) const SizedBox(width: 2),
                if (hasP2)
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF58A6FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF58A6FF).withValues(alpha: 0.8),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.isVsAi ? '🤖' : '2',
                        style: const TextStyle(
                          fontSize: 6,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _LegendChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
