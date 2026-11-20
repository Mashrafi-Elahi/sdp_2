import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dice_game/screens/game_screen.dart';

void main() {
  testWidgets('Game screen shows one panel per player',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GameScreen(playerCount: 3, diceCount: 2)),
    );

    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);
    expect(find.text('Player 3'), findsOneWidget);
    expect(find.text('ROLL DICE'), findsOneWidget);
  });
}
