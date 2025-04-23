import 'package:flutter/material.dart';
import 'package:word_hunt/word_hunt/core/theme/app_theme.dart';
import 'package:word_hunt/word_hunt/domain/entities/game.dart';

class GameOverSummary extends StatefulWidget {
  final int score;
  final int wordsFound;
  final int timeSpent;
  final GameDifficulty difficulty;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;
  
  const GameOverSummary({
    super.key,
    required this.score,
    required this.wordsFound,
    required this.timeSpent,
    required this.difficulty,
    required this.onPlayAgain,
    required this.onExit,
  });
  
  @override
  State<GameOverSummary> createState() => _GameOverSummaryState();
}

class _GameOverSummaryState extends State<GameOverSummary> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Başlık
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Oyun Bitti!',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Tebrikler! İşte sonuçlarınız:',
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Score
                  _buildScoreCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Stats
                  _buildStatsCard(),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Play again button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onPlayAgain,
                          icon: const Icon(Icons.replay),
                          label: const Text('Tekrar Oyna'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Exit button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onExit,
                          icon: const Icon(Icons.home),
                          label: const Text('Ana Menü'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 34,
          ),
          const SizedBox(width: 12),
          TweenAnimationBuilder<int>(
            duration: const Duration(milliseconds: 1500),
            tween: IntTween(begin: 0, end: widget.score),
            builder: (context, value, child) {
              return Text(
                '$value',
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Words found
          _buildStatRow(
            icon: Icons.search,
            label: 'Bulunan Kelime',
            value: widget.wordsFound.toString(),
            color: AppTheme.secondaryColor,
          ),
          
          const Divider(height: 24),
          
          // Time spent
          _buildStatRow(
            icon: Icons.timer,
            label: 'Oyun Süresi',
            value: '${widget.timeSpent} sn',
            color: AppTheme.warningColor,
          ),
          
          const Divider(height: 24),
          
          // Difficulty
          _buildStatRow(
            icon: Icons.trending_up,
            label: 'Zorluk Seviyesi',
            value: _getDifficultyName(widget.difficulty),
            color: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textColor.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
}