import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:word_hunt/word_hunt/core/constants/app_constants.dart';
import 'package:word_hunt/word_hunt/core/theme/app_theme.dart';
import 'package:word_hunt/word_hunt/data/services/word_dictionary_service.dart';
import 'package:word_hunt/word_hunt/domain/entities/game.dart';
import 'package:word_hunt/word_hunt/presentation/widgets/found_words_list.dart';
import 'package:word_hunt/word_hunt/presentation/widgets/game_over_summary.dart';
import 'package:word_hunt/word_hunt/presentation/widgets/letter_grid.dart';
import 'package:word_hunt/word_hunt/presentation/widgets/timer_widget.dart';

class WordHuntScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  final Function(int, Map<String, dynamic>) onScoreUpdated;
  final VoidCallback onGameOver;

  const WordHuntScreen({
    super.key,
    required this.difficulty,
    required this.onScoreUpdated,
    required this.onGameOver,
  });

  @override
  State<WordHuntScreen> createState() => _WordHuntScreenState();
}

class _WordHuntScreenState extends State<WordHuntScreen> with TickerProviderStateMixin {
  // Late değişkenlerine başlangıç değerleri atıyoruz
  late int timeLeft = 60; // Varsayılan değer, _initializeGame'de güncellenir
  late int score = 0;
  late List<String> letters = []; // Boş liste ile başlat
  late Set<String> foundWords = {}; // Boş set ile başlat
  Timer? timer;
  late WordDictionaryService _wordDictionaryService;
  late GlobalKey<LetterGridState> _letterGridKey;
  bool _isGameOver = false;
  bool _isLoading = true; // Sözlük yüklenirken loading göster
  
  // Animation controllers
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  // Türkçe sesli harfler
  final List<String> vowels = ['A', 'E', 'I', 'İ', 'O', 'Ö', 'U', 'Ü'];
  
  // Türkçe sessiz harfler
  final List<String> consonants = [
    'B', 'C', 'Ç', 'D', 'F', 'G', 'Ğ', 'H', 'J', 'K', 'L', 'M',
    'N', 'P', 'R', 'S', 'Ş', 'T', 'V', 'Y', 'Z'
  ];
  
  // Türkçe harflerin frekansları
  final Map<String, double> letterFrequency = {
    'A': 12.0, 'E': 9.0, 'I': 8.0, 'İ': 8.0, 'O': 3.0, 'Ö': 1.0, 'U': 3.0, 'Ü': 2.0,
    'B': 3.0, 'C': 1.0, 'Ç': 1.5, 'D': 5.0, 'F': 1.0, 'G': 1.5, 'Ğ': 1.0, 'H': 1.0,
    'J': 0.5, 'K': 6.0, 'L': 6.0, 'M': 4.0, 'N': 7.0, 'P': 1.0, 'R': 7.0, 'S': 3.0,
    'Ş': 1.5, 'T': 5.0, 'V': 1.0, 'Y': 3.0, 'Z': 1.5,
  };
  
  @override
  void initState() {
    super.initState();
    _letterGridKey = GlobalKey<LetterGridState>();
    _wordDictionaryService = WordDictionaryService();
    _initializeAnimations();
    _initializeGame();
  }
  
  void _initializeAnimations() {
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scoreAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  Future<void> _initializeGame() async {
    setState(() {
      _isLoading = true;
    });
    
    // Initialize the dictionary service
    try {
      await _wordDictionaryService.initialize();
      print("Sözlük başarıyla yüklendi!");
    } catch (e) {
      print("Sözlük yüklenirken hata oluştu: $e");
    }
    
    // Zorluk seviyesine göre süre ayarlanır
    timeLeft = _getTimeForDifficulty(widget.difficulty);
    score = 0;
    letters = generateLetters();
    foundWords = {};
    _isGameOver = false;
    
    // Debug için, oluşturulan harfleri yazdır
    print("Oluşturulan harfler: $letters");
    
    // Mevcut harflerle oluşturulabilecek kelimeleri test et
    _testPossibleWords();
    
    widget.onScoreUpdated(score, {
      'wordsFound': foundWords.length,
      'timeSpent': _getTimeForDifficulty(widget.difficulty) - timeLeft,
    });
    
    setState(() {
      _isLoading = false;
    });
    
    // Zamanlayıcıyı başlat
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          endGame();
        }
      });
    });
  }
  
  // Debug amaçlı: mevcut harflerle kaç kelime oluşturulabilir?
  void _testPossibleWords() {
    List<String> upperCaseLetters = letters.map((letter) => letter.toUpperCase()).toList();
    List<String> possibleWords = _wordDictionaryService.getPossibleWords(upperCaseLetters, widget.difficulty);
    print("Bu harflerle oluşturulabilecek kelime sayısı: ${possibleWords.length}");
    if (possibleWords.isNotEmpty) {
      print("Örnek kelimeler: ${possibleWords.take(10).join(", ")}");
    } else {
      print("Hiç kelime bulunmadı! Kelime sözlüğü düzgün yüklenmemiş olabilir.");
    }
  }
  
  int _getTimeForDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return AppConstants.wordHuntEasyTimeLimit;
      case GameDifficulty.medium:
        return AppConstants.wordHuntMediumTimeLimit;
      case GameDifficulty.hard:
        return AppConstants.wordHuntHardTimeLimit;
    }
  }
  
  List<String> generateLetters() {
    final random = Random();
    final letters = <String>[];
    
    // 4x4 grid için 16 harf üretiyoruz
    // En az 4 sesli harf olsun (daha dengeli olması için)
    int vowelCount = 0;
    int maxVowels = 6; // Maksimum sesli harf sayısı
    
    // Öncelikle rastgele harfler seçelim, sesli/sessiz dengesini koruyarak
    while (letters.length < 16) {
      // Eğer yetersiz sesli harf varsa, sesli harf ekle
      if (vowelCount < 4 && (letters.length > 10 || random.nextDouble() < 0.4)) {
        final vowel = vowels[random.nextInt(vowels.length)];
        letters.add(vowel);
        vowelCount++;
        continue;
      }
      
      // Eğer çok fazla sesli harf eklenirse, sessiz harf ekle
      if (vowelCount >= maxVowels) {
        final consonant = consonants[random.nextInt(consonants.length)];
        letters.add(consonant);
        continue;
      }
      
      // Frekansa dayalı harf seçimi
      // Tüm harflerin toplamını hesapla
      final double totalFrequency = letterFrequency.values.reduce((a, b) => a + b);
      
      // 0 ile toplam frekans arasında rastgele bir değer seç
      double randomValue = random.nextDouble() * totalFrequency;
      
      // Seçilen değere göre harfi belirle
      String selectedLetter = '';
      for (final entry in letterFrequency.entries) {
        randomValue -= entry.value;
        if (randomValue <= 0) {
          selectedLetter = entry.key;
          break;
        }
      }
      
      // Eğer harf seçilmediyse (olmaması gerekir ama önlem olarak)
      if (selectedLetter.isEmpty) {
        selectedLetter = letterFrequency.keys.first;
      }
      
      // Aynı harfin çok fazla tekrarlanmasını önle (maksimum 2 adet)
      if (letters.where((l) => l == selectedLetter).length < 2) {
        letters.add(selectedLetter);
        
        // Sesli harf sayısını güncelle
        if (vowels.contains(selectedLetter)) {
          vowelCount++;
        }
      }
    }
    
    // Harfleri karıştır
    letters.shuffle();
    
    return letters;
  }
  
  bool isValidWord(String word) {
    // Minimum kelime uzunluğu kontrolü
    if (word.length < AppConstants.wordHuntMinimumWordLength) {
      return false;
    }
    
    // Zaten bulunmuş bir kelime mi kontrolü
    if (foundWords.contains(word)) {
      return false;
    }
    
    // Verilen harflerle oluşturulabilir mi kontrolü
    final Map<String, int> letterCounts = {};
    for (final letter in letters) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }
    
    for (int i = 0; i < word.length; i++) {
      final letter = word[i];
      if ((letterCounts[letter] ?? 0) <= 0) {
        return false;
      }
      letterCounts[letter] = letterCounts[letter]! - 1;
    }
    
    // Türkçe kelime kontrolü
    return _wordDictionaryService.isValidWord(word);
  }
  
  void submitWord(String word) {
    if (isValidWord(word)) {
      // Kelime uzunluğuna göre puan hesapla
      final int wordPoints = calculatePoints(word);
      
      setState(() {
        foundWords.add(word);
        
        // Hesaplanan puanı toplam skora ekle
        score += wordPoints;
        
        // Puan animasyonu
        _scoreAnimationController.reset();
        _scoreAnimationController.forward();
        
        // Skor güncelleme
        widget.onScoreUpdated(score, {
          'wordsFound': foundWords.length,
          'timeSpent': _getTimeForDifficulty(widget.difficulty) - timeLeft,
        });
      });
      
      // Başarılı bir kelime bulunduğunda hafif geribildirim ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$word: +$wordPoints puan!'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
        ),
      );
      
      // Input alanını temizle
      _letterGridKey.currentState?.clearSelection();
      
    } else if (word.length >= AppConstants.wordHuntMinimumWordLength) {
      // Geçersiz kelime girişi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçersiz veya zaten bulunan kelime!'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(8),
        ),
      );
      
      // Input alanını temizle
      _letterGridKey.currentState?.clearSelection();
    }
  }
  
  int calculatePoints(String word) {
    switch (word.length) {
      case 3: return 3;
      case 4: return 5;
      case 5: return 8;
      default: return word.length + 5; // 6+ harfli kelimeler için özel puanlama
    }
  }
  
  void endGame() {
    timer?.cancel();
    timer = null;
    
    setState(() {
      _isGameOver = true;
    });
  }
  
  void _restartGame() {
    setState(() {
      _isGameOver = false;
      _initializeGame();
    });
  }
  
  void _exitGame() {
    widget.onGameOver();
  }
  
  @override
  void dispose() {
    timer?.cancel();
    _scoreAnimationController.dispose();
    _pulseAnimationController.dispose(); // _pulseAnimationController'ı da dispose etmemiz gerek
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.95),
              AppTheme.primaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Kelime sözlüğü yükleniyor...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  // Main game content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Üst bilgi bölümü (süre ve skor)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Süre göstergesi
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseAnimationController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: timeLeft < 10 ? _pulseAnimation.value : 1.0,
                                        child: TimerWidget(timeLeft: timeLeft),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              
                              // Skor
                              AnimatedBuilder(
                                animation: _scoreAnimationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scoreAnimation.value,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accentColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: _scoreAnimationController.value * 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$score',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Harf ızgarası - zorluk seviyesini iletiyoruz
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: LetterGrid(
                            key: _letterGridKey,
                            letters: letters,
                            onWordSelected: submitWord,
                            difficulty: widget.difficulty,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Bulunan kelimeler başlığı
                        Row(
                          children: [
                            const Icon(Icons.checklist, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Bulunan Kelimeler (${foundWords.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Bulunan kelimeler listesi
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: FoundWordsList(foundWords: foundWords.toList()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Game Over overlay
                  if (_isGameOver)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: GameOverSummary(
                          score: score,
                          wordsFound: foundWords.length,
                          timeSpent: _getTimeForDifficulty(widget.difficulty) - timeLeft,
                          difficulty: widget.difficulty,
                          onPlayAgain: _restartGame,
                          onExit: _exitGame,
                        ),
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}