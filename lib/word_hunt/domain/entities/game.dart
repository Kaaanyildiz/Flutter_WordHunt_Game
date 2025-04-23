import 'package:flutter/material.dart';

/// Difficulty level for games
enum GameDifficulty {
  easy,
  medium,
  hard,
}

/// Game entity
/// 
/// Represents a game in the application.
class Game {
  /// Unique identifier for the game
  final String id;
  
  /// Name of the game
  final String name;
  
  /// Description of the game
  final String description;
  
  /// Icon path for the game
  final String iconPath;
  
  /// Route path for the game
  final String routePath;
  
  /// Whether the game supports difficulty levels
  final bool hasDifficultyLevels;
  
  /// Whether the game has sound effects
  final bool hasSoundEffects;
  
  /// Whether the game is available offline
  final bool isOfflineAvailable;
  
  /// Whether the game has a tutorial
  final bool hasTutorial;
  
  /// Tags for the game
  final List<String> tags;
  
  /// Icon data for the game
  final IconData iconData;

  /// Constructor for Game entity
  const Game({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.routePath,
    required this.iconData,
    this.hasDifficultyLevels = false,
    this.hasSoundEffects = false,
    this.isOfflineAvailable = true,
    this.hasTutorial = false,
    this.tags = const [],
  });
}