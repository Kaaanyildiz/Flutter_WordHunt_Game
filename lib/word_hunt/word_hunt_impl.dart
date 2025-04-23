import 'package:flutter/material.dart';
import 'package:word_hunt/word_hunt/core/constants/app_constants.dart';
import 'package:word_hunt/word_hunt/domain/entities/game.dart';
import 'package:word_hunt/word_hunt/domain/entities/game_interface.dart';
import 'package:word_hunt/word_hunt/domain/entities/score.dart';
import 'package:word_hunt/word_hunt/presentation/screens/word_hunt_screen.dart';
import 'package:word_hunt/word_hunt/data/services/word_dictionary_service.dart';

class WordHuntGame implements GameInterface {
  // Seçilen zorluk seviyesi
  GameDifficulty selectedDifficulty = GameDifficulty.medium;
  
  // Kelime sözlüğü servisi
  final WordDictionaryService _wordDictionaryService = WordDictionaryService();
  
  // Oyun durumu
  bool _isGameRunning = false;
  
  /// Oyunun initialize edilmesi
  Future<void> initialize() async {
    try {
      await _wordDictionaryService.initialize();
      print("Kelime sözlüğü başarıyla yüklendi!");
    } catch (e) {
      print("Kelime sözlüğü yüklenirken hata oluştu: $e");
    }
  }

  @override
  Game get gameInfo => const Game(
    id: 'word_hunt',
    name: 'Kelime Avı',
    description: 'Harflerden anlamlı kelimeler oluştur ve puanları topla.',
    iconPath: 'assets/images/word_hunt_icon.png', // Eğer bu dosya yoksa, mevcut bir ikon ile değiştirilmeli
    routePath: AppConstants.wordHuntRoute,
    tags: ['kelime', 'bulmaca', 'zeka'],
    hasDifficultyLevels: true,
    hasSoundEffects: true,
    isOfflineAvailable: true,
    hasTutorial: true,
    iconData: Icons.abc,
  );

  @override
  List<GameDifficulty> get supportedDifficulties => [
    GameDifficulty.easy,
    GameDifficulty.medium,
    GameDifficulty.hard,
  ];

  @override
  Widget buildGame({
    required BuildContext context,
    required GameDifficulty difficulty,
    required Function(Score) onScoreUpdated,
    required Function() onGameOver,
  }) {
    return WordHuntScreen(
      difficulty: difficulty,
      onScoreUpdated: (score, metadata) {
        onScoreUpdated(Score(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          gameId: gameInfo.id,
          userId: 'current_user', // Gerçek kullanıcı ID'si olmalı
          value: score,
          difficulty: difficulty,
          date: DateTime.now(),
          metadata: metadata,
        ));
      },
      onGameOver: onGameOver,
    );
  }

  @override
  Widget buildDifficultySelection({
    required BuildContext context,
    required Function(GameDifficulty) onDifficultySelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Zorluk Seviyesi Seçin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: supportedDifficulties.map((difficulty) {
            final difficultyName = _getDifficultyName(difficulty);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: () => onDifficultySelected(difficulty),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getDifficultyColor(difficulty),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  difficultyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => onDifficultySelected(GameDifficulty.medium), // Orta zorluk ile hemen başla
          icon: const Icon(Icons.play_arrow),
          label: const Text('Hemen Başla', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }
  
  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Colors.blue;
      case GameDifficulty.medium:
        return Colors.orange;
      case GameDifficulty.hard:
        return Colors.red;
    }
  }
  
  String _getDifficultyName(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Kolay';
      case GameDifficulty.medium:
        return 'Orta';
      case GameDifficulty.hard:
        return 'Zor';
    }
  }

  @override
  Widget buildGameOverScreen({
    required BuildContext context,
    required Score score,
    required Function() onPlayAgain,
    required Function() onExit,
  }) {
    // Oyun içinde özel bir oyun sonu ekranı kullanıyor, ancak burası null olamaz
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oyun Bitti',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Skorunuz: ${score.value}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onPlayAgain,
                  child: const Text('Tekrar Oyna'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: onExit,
                  child: const Text('Çıkış'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTutorial({
    required BuildContext context,
    required Function() onTutorialCompleted,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nasıl Oynanır'),
        actions: [
          TextButton(
            onPressed: onTutorialCompleted,
            child: const Text('Atla', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelime Avı',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu oyunda harflerden anlamlı kelimeler oluşturarak puan toplayacaksınız.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              1,
              'Harfler 4x4 bir ızgarada gösterilir. Kelime oluşturmak için harflere sırayla dokunun.',
            ),
            _buildTutorialStep(
              2,
              'Her kelime en az 3 harf içermelidir.',
            ),
            _buildTutorialStep(
              3,
              'Harflerin rengi size ipucu verir: Yeşil harfler geçerli bir kelime oluşturabileceğinizi, kırmızı harfler ise geçersiz bir yolda olduğunuzu gösterir.',
            ),
            _buildTutorialStep(
              4,
              'Kelime uzunluğuna göre puan kazanırsınız: 3 harf: 3 puan, 4 harf: 5 puan, 5 harf: 8 puan, 6+ harf: harf sayısı + 5 puan.',
            ),
            const SizedBox(height: 8),
            _buildTutorialStep(
              5,
              'Zorluk seviyeleri süreyi etkiler: Kolay: 90 saniye, Orta: 60 saniye, Zor: 45 saniye.',
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: onTutorialCompleted,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Anladım, Hadi Oynayalım!'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialStep(int stepNumber, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void startGame(GameDifficulty difficulty) {
    // No-op, game starts automatically in WordHuntScreen
  }

  @override
  void pauseGame() {
    // Bu oyunda özel bir duraklatma işlemi gerekmiyor
  }

  @override
  void resumeGame() {
    // Bu oyunda özel bir devam etme işlemi gerekmiyor
  }

  @override
  void resetGame() {
    // Bu oyunda özel bir sıfırlama işlemi gerekmiyor
    // Oyun yeniden başlatıldığında zaten sıfırlanıyor
  }

  @override
  void dispose() {
    // Kullanılan kaynakları temizle
    // Bu oyunda özel temizleme gerekmiyor
  }

  @override
  void endGame() {
    // Interface'in varsayılan implementasyonunu taklit et
    try {
      pauseGame();
      // Oyun için özel temizleme işlemleri buraya eklenebilir
    } catch (e) {
      // Hataları güvenli şekilde yakala
      print("Error in endGame(): $e");
    }
  }
}