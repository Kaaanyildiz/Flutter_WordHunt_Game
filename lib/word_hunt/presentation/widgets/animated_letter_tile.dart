import 'package:flutter/material.dart';
import 'package:word_hunt/word_hunt/core/theme/app_theme.dart';

/// Harf durumu - renk kodlaması için
enum LetterStatus {
  neutral,    // Seçilmemiş
  selected,   // Seçilmiş, normal durum
  valid,      // Seçilmiş, geçerli bir kelime potansiyeli
  invalid     // Seçilmiş, geçersiz bir kelime potansiyeli
}

class AnimatedLetterTile extends StatefulWidget {
  final String letter;
  final bool isSelected;
  final VoidCallback onTap;
  final LetterStatus status;
  
  const AnimatedLetterTile({
    super.key,
    required this.letter,
    this.isSelected = false,
    required this.onTap,
    this.status = LetterStatus.neutral,
  });

  @override
  State<AnimatedLetterTile> createState() => _AnimatedLetterTileState();
}

class _AnimatedLetterTileState extends State<AnimatedLetterTile> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bounceAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut, // easeOutBounce -> bounceOut olarak düzeltildi
    ));
    
    // Wiggle animation when selected
    if (widget.isSelected) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedLetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Duruma göre renk döndürür
  Color _getColorForStatus(BuildContext context) {
    switch (widget.status) {
      case LetterStatus.neutral:
        return AppTheme.primaryColor;
      case LetterStatus.selected:
        return AppTheme.secondaryColor;
      case LetterStatus.valid:
        return AppTheme.accentColor; // Geçerli kelime için yeşil
      case LetterStatus.invalid:
        return AppTheme.warningColor; // Geçersiz kelime için turuncu
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Transform.translate(
                offset: Offset(0, widget.isSelected ? -_bounceAnimation.value : 0), // Boolean koşul hatası düzeltildi
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getColorForStatus(context),
                        _getColorForStatus(context).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getColorForStatus(context).withOpacity(0.4),
                        blurRadius: widget.isSelected ? 12 : 4,
                        spreadRadius: widget.isSelected ? 2 : 0,
                        offset: widget.isSelected 
                            ? const Offset(0, 4) 
                            : const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Glow effect for valid words
                      if (widget.status == LetterStatus.valid)
                        Positioned.fill(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.accentColor.withOpacity(0.8),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      
                      // Letter
                      Center(
                        child: Text(
                          widget.letter,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: widget.isSelected ? [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black26,
                                offset: const Offset(0, 2),
                              ),
                            ] : [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}