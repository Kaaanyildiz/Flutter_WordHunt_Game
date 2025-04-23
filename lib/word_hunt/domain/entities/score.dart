import 'package:word_hunt/word_hunt/domain/entities/game.dart';

/// Score entity
/// 
/// Represents a score entry for a game.
class Score {
  /// Unique identifier for the score
  final String id;
  
  /// ID of the game
  final String gameId;
  
  /// ID of the user
  final String userId;
  
  /// Score value
  final int value;
  
  /// Difficulty level of the game when the score was achieved
  final GameDifficulty difficulty;
  
  /// Date when the score was achieved
  final DateTime date;
  
  /// Additional metadata for the score (e.g., game-specific information)
  final Map<String, dynamic>? metadata;

  /// Constructor for Score entity
  const Score({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.value,
    required this.difficulty,
    required this.date,
    this.metadata,
  });
}