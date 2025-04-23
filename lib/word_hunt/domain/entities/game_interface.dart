import 'package:flutter/material.dart';
import 'package:word_hunt/word_hunt/domain/entities/game.dart';
import 'package:word_hunt/word_hunt/domain/entities/score.dart';

/// Game interface for all games in the application
abstract class GameInterface {
  /// Game information
  Game get gameInfo;

  /// Supported difficulty levels
  List<GameDifficulty> get supportedDifficulties;

  /// Build the game widget
  Widget buildGame({
    required BuildContext context,
    required GameDifficulty difficulty,
    required Function(Score) onScoreUpdated,
    required Function() onGameOver,
  });

  /// Build the difficulty selection widget
  Widget buildDifficultySelection({
    required BuildContext context,
    required Function(GameDifficulty) onDifficultySelected,
  });

  /// Build the game over screen
  Widget buildGameOverScreen({
    required BuildContext context,
    required Score score,
    required Function() onPlayAgain,
    required Function() onExit,
  });

  /// Build the tutorial screen
  Widget buildTutorial({
    required BuildContext context,
    required Function() onTutorialCompleted,
  });

  /// Start the game with the specified difficulty
  void startGame(GameDifficulty difficulty);

  /// Pause the game
  void pauseGame();

  /// Resume the game
  void resumeGame();

  /// Reset the game
  void resetGame();

  /// End the game
  void endGame();

  /// Clean up resources
  void dispose();
}