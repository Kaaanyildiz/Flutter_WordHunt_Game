import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:word_hunt/word_hunt/core/constants/app_constants.dart';
import 'package:word_hunt/word_hunt/core/theme/app_theme.dart';
import 'package:word_hunt/word_hunt/domain/entities/game.dart';
import 'package:word_hunt/word_hunt/word_hunt_impl.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (sadece dikey modda çalışsın)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.primaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize word dictionary service
  final wordHuntGame = WordHuntGame();
  await wordHuntGame.initialize();
  
  // Run app
  runApp(MyApp(wordHuntGame: wordHuntGame));
}

class MyApp extends StatelessWidget {
  final WordHuntGame wordHuntGame;
  
  const MyApp({
    Key? key,
    required this.wordHuntGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLanguage.supportedLanguages
          .map((language) => Locale(language.code))
          .toList(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.primaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: const WordHuntHomePage(),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Word Hunt ana sayfa widget'ı
class WordHuntHomePage extends StatefulWidget {
  const WordHuntHomePage({Key? key}) : super(key: key);

  @override
  State<WordHuntHomePage> createState() => _WordHuntHomePageState();
}

class _WordHuntHomePageState extends State<WordHuntHomePage> with SingleTickerProviderStateMixin {
  final WordHuntGame game = WordHuntGame();
  bool showTutorial = false;
  bool isGameRunning = false;
  
  // Seçilen zorluk seviyesini takip etmek için
  GameDifficulty? selectedDifficulty;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Oyunu başlatmak için fonksiyon
  void _startGame() {
    if (selectedDifficulty != null) {
      setState(() {
        game.selectedDifficulty = selectedDifficulty!;
        isGameRunning = true;
      });
      game.startGame(selectedDifficulty!);
    } else {
      // Eğer zorluk seviyesi seçilmemişse kullanıcıyı bilgilendir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir zorluk seviyesi seçin'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (showTutorial) {
      return game.buildTutorial(
        context: context,
        onTutorialCompleted: () {
          setState(() {
            showTutorial = false;
          });
        },
      );
    }

    if (isGameRunning) {
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            isGameRunning = false;
          });
          return false;
        },
        child: game.buildGame(
          context: context,
          difficulty: game.selectedDifficulty,
          onScoreUpdated: (score) {
            // Score kaydedilebilir
          },
          onGameOver: () {
            setState(() {
              isGameRunning = false;
            });
          },
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo ve başlık
                Hero(
                  tag: 'game_logo',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.abc,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kelime Avı',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black26,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kelimeleri Bul, Puanları Topla!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Zorluk Seviyesi başlığı
                const Text(
                  'ZORLUK SEVİYESİ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Zorluk Seviyesi Butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildDifficultyButton(
                        text: 'KOLAY',
                        color: Colors.blue,
                        isSelected: selectedDifficulty == GameDifficulty.easy,
                        onPressed: () {
                          setState(() {
                            selectedDifficulty = GameDifficulty.easy;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyButton(
                        text: 'ORTA',
                        color: AppTheme.warningColor,
                        isSelected: selectedDifficulty == GameDifficulty.medium,
                        onPressed: () {
                          setState(() {
                            selectedDifficulty = GameDifficulty.medium;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyButton(
                        text: 'ZOR',
                        color: Colors.red,
                        isSelected: selectedDifficulty == GameDifficulty.hard,
                        onPressed: () {
                          setState(() {
                            selectedDifficulty = GameDifficulty.hard;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Oyun Başlatma Butonu
                _buildAnimatedButton(
                  icon: Icons.play_arrow,
                  text: 'OYUNA BAŞLA',
                  color: selectedDifficulty != null ? AppTheme.accentColor : Colors.grey,
                  onPressed: _startGame,
                ),
                
                const SizedBox(height: 40),
                
                // Nasıl Oynanır Butonu
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      showTutorial = true;
                    });
                  },
                  icon: const Icon(
                    Icons.help_outline,
                    color: Colors.white70,
                  ),
                  label: const Text(
                    'NASIL OYNANIR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAnimatedButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: Icon(icon, size: 30),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDifficultyButton({
    required String text,
    required Color color,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isSelected ? 0.5 : 0.3),
            blurRadius: isSelected ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : color.withOpacity(0.7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: isSelected ? BorderSide(color: Colors.white, width: 2) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}