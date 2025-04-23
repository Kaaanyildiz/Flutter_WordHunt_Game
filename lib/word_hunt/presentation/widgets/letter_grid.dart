import 'package:flutter/material.dart';
import 'package:word_hunt/word_hunt/data/services/word_dictionary_service.dart';
import 'dart:math';

import 'package:word_hunt/word_hunt/domain/entities/game.dart';
import 'package:word_hunt/word_hunt/presentation/widgets/animated_letter_tile.dart';

class LetterGrid extends StatefulWidget {
  final List<String> letters;
  final Function(String)? onWordSelected;
  final GameDifficulty difficulty;

  const LetterGrid({
    super.key,
    required this.letters,
    this.onWordSelected,
    required this.difficulty,
  });

  @override
  LetterGridState createState() => LetterGridState();
}

class LetterGridState extends State<LetterGrid> {
  final List<int> _selectedIndices = [];
  final Map<int, LetterStatus> _letterStatuses = {};
  String _currentWord = '';
  final _wordService = WordDictionaryService();
  final List<String> _usedWords = []; // Kullanılmış kelimeleri takip eden liste
  List<String> _possibleWords = []; // Bu girdeki harflerle oluşturulabilecek tüm kelimeler
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _resetLetterStatuses();
    
    // Widget oluşturulduğunda mümkün olan kelimeleri hesapla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePossibleWords();
    });
  }
  
  @override
  void didUpdateWidget(LetterGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Harfler değiştiyse yeniden hesapla
    if (oldWidget.letters != widget.letters) {
      _calculatePossibleWords();
    }
  }
  
  // Bu grid ile oluşturulabilecek tüm kelimeleri hesapla
  void _calculatePossibleWords() {
    // Harfleri büyük harfe çevir
    List<String> upperCaseLetters = widget.letters.map((letter) => letter.toUpperCase()).toList();
    
    // Olası kelimeleri hesapla
    _possibleWords = _wordService.getPossibleWords(upperCaseLetters, widget.difficulty);
    
    print("Hesaplanan olası kelime sayısı: ${_possibleWords.length}");
    if (_possibleWords.length > 0) {
      print("Örnek kelimeler: ${_possibleWords.take(min(10, _possibleWords.length)).join(", ")}");
      setState(() {
        _initialized = true;
      });
    } else {
      print("UYARI: Hiç olası kelime bulunamadı!");
    }
  }

  // Seçilen kelime, mevcut grid ile oluşturulabilecek bir kelimenin öneki mi?
  bool _isPrefixOfPossibleWord(String prefix) {
    if (prefix.isEmpty) return true;
    String upperPrefix = prefix.toUpperCase();
    
    // Örnek bir kelime olarak prefix'in kendisi doğrudan olası kelimelerden biri mi?
    if (_possibleWords.contains(upperPrefix)) {
      return true;
    }
    
    // Herhangi bir olası kelime bu önek ile başlıyor mu?
    for (String word in _possibleWords) {
      if (word.startsWith(upperPrefix)) {
        return true;
      }
    }
    return false;
  }

  void _resetLetterStatuses() {
    setState(() {
      for (int i = 0; i < widget.letters.length; i++) {
        _letterStatuses[i] = LetterStatus.neutral;
      }
    });
  }

  void _selectLetter(int index) {
    if (!_initialized) {
      print("Henüz olası kelimeler hesaplanmadı!");
      return;
    }
    
    // Son seçilen harfin tekrar seçilmesi durumunda, bu harfi kaldır
    if (_selectedIndices.isNotEmpty && _selectedIndices.last == index) {
      setState(() {
        _selectedIndices.removeLast();
        _letterStatuses[index] = LetterStatus.neutral;
        _currentWord = _currentWord.substring(0, _currentWord.length - 1);
        
        // Kalan harflerin durumlarını güncelle
        _updateLetterStatuses();
      });
      return;
    }

    // Zaten seçilmiş bir harf ise, işlem yapma
    if (_selectedIndices.contains(index)) {
      return;
    }
    
    // Yeni harf ekle
    setState(() {
      _selectedIndices.add(index);
      _currentWord += widget.letters[index];
      
      // Geçerli kelime kontrolü
      bool isValid = _isValidWord();
      bool isPotential = _isPrefixOfPossibleWord(_currentWord);
      
      // Debug çıktıları
      print("Seçilen Kelime: $_currentWord");
      print("Geçerli mi: $isValid");
      print("Potansiyel mi: $isPotential");
      
      // Harflerin durumlarını güncelle
      _updateLetterStatuses();
      
      // Eğer geçerli bir kelime ise, callback'i çağır
      if (isValid) {
        _handleValidWord();
      }
    });
  }
  
  void _updateLetterStatuses() {
    // Öncelikle tüm seçili harflerin durumunu selected olarak ayarla
    for (var idx in _selectedIndices) {
      _letterStatuses[idx] = LetterStatus.selected;
    }
    
    // Şimdi geçerli kelime kontrolü yap
    if (_currentWord.isEmpty) return;
    
    // Sadece mevcut grid ile oluşturulabilecek kelimelere doğru ilerliyorsa yeşil göster
    bool isPotential = _isPrefixOfPossibleWord(_currentWord);
    
    // Tüm seçili harfleri işaretle
    for (var idx in _selectedIndices) {
      _letterStatuses[idx] = isPotential ? LetterStatus.valid : LetterStatus.invalid;
    }
  }
  
  bool _isValidWord() {
    // Minimum 3 harfli kelime kontrolü 
    if (_currentWord.length < 3) return false;
    
    // Daha önce kullanılmış mı kontrol et
    if (_usedWords.contains(_currentWord)) return false;
    
    // Kelimenin sözlükte olup olmadığını kontrol et
    bool isInDictionary = _wordService.isValidWord(_currentWord);
    
    // Kelimenin mevcut grid ile oluşturulabilir olup olmadığını kontrol et
    bool canBeFormed = _possibleWords.contains(_currentWord.toUpperCase());
    
    return isInDictionary && canBeFormed;
  }
  
  void _handleValidWord() {
    if (widget.onWordSelected != null) {
      // Kullanılmış kelimeler listesine ekle
      _usedWords.add(_currentWord);
      
      // Kullanıcıya görsel geribildirim için kısa bir gecikme ekleyelim
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onWordSelected!(_currentWord);
        clearSelection();
      });
    }
  }
  
  void clearSelection() {
    setState(() {
      _selectedIndices.clear();
      _currentWord = '';
      _resetLetterStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Current word preview
              if (_currentWord.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _currentWord,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      // Rengi duruma göre değiştir
                      color: _updateGetCurrentWordColor(),
                    ),
                  ),
                ),
              
              // Letter grid - 4x4 grid olarak değiştir
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4x4 grid
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: widget.letters.length, // 16 harf
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndices.contains(index);
                  return AnimatedLetterTile(
                    letter: widget.letters[index],
                    isSelected: isSelected,
                    status: _letterStatuses[index] ?? LetterStatus.neutral,
                    onTap: () => _selectLetter(index),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Geçerli kelimeyi temizle butonu
        if (_selectedIndices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextButton.icon(
              onPressed: clearSelection,
              icon: const Icon(Icons.clear),
              label: const Text('Temizle'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
  
  // Mevcut kelimenin rengini durumuna göre belirle
  Color _updateGetCurrentWordColor() {
    // Daha önce kullanılmış mı kontrol et
    if (_usedWords.contains(_currentWord)) {
      return Colors.red.shade600;
    }
    
    // Geçerli kelime kontrolü
    bool isValid = _currentWord.length >= 3 && _isValidWord();
    bool isPotential = _currentWord.length < 3 || _isPrefixOfPossibleWord(_currentWord);
    
    if (isValid) {
      return Colors.green.shade600;
    } else if (isPotential) {
      return Colors.green.shade600;
    } else {
      return Colors.red.shade600;
    }
  }
}