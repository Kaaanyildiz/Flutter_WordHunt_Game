import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:word_hunt/word_hunt/data/models/trie.dart';
import 'package:word_hunt/word_hunt/domain/entities/game.dart';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Service to load and manage the Turkish word dictionary
class WordDictionaryService {
  static const String _dictPath = 'assets/words_lib.json';
  static const String _encryptionKey = 'word_hunter_secret_key_2025'; // Şifreleme anahtarı
  
  /// The loaded word dictionary
  List<String> _dictionary = [];
  
  /// Trie veri yapısı
  final Trie _trie = Trie();
  
  /// Singleton pattern
  static final WordDictionaryService _instance = WordDictionaryService._internal();
  
  factory WordDictionaryService() => _instance;
  
  WordDictionaryService._internal();
  
  bool _isInitialized = false;

  /// Initialize the dictionary by loading words from the JSON file
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final String jsonData = await rootBundle.loadString(_dictPath);
      final bool isEncrypted = _isJsonEncrypted(jsonData);
      
      // Decrypt if the file is encrypted
      final String decryptedJson = isEncrypted 
          ? _decryptData(jsonData) 
          : jsonData;
      
      final List<dynamic> wordList = json.decode(decryptedJson);
      _dictionary = wordList.cast<String>();
      // Ensure all words are uppercase for consistent comparison
      _dictionary = _dictionary.map((word) => word.toUpperCase()).toList();
      
      // Trie yapısını doldur
      for (final word in _dictionary) {
        _trie.insert(word);
      }
      
      _isInitialized = true;
      print('Dictionary loaded with ${wordList.length} words');
    } catch (e) {
      print('Error loading word dictionary: $e');
      // Fallback to a small default list
      _dictionary = [
        'ANA', 'BAL', 'CAM', 'DIŞ', 'ELİ', 'FEN', 'GÖL', 'HOŞ', 'İKİ', 'KUM',
        'LİG', 'MAL', 'NEF', 'ODA', 'PİL', 'RUH', 'SİM', 'TAŞ', 'ULU', 'VAR'
      ];
      
      // Trie yapısını fallback liste ile doldur
      for (final word in _dictionary) {
        _trie.insert(word);
      }
    }
  }
  
  /// Check if a word exists in the dictionary
  bool isValidWord(String word) {
    if (!_isInitialized) {
      throw Exception('Dictionary not initialized! Call initialize() first.');
    }
    
    // En az 3 harfli kelimeler geçerli
    if (word.length < 3) return false;
    
    return _trie.search(word.toUpperCase());
  }
  
  /// Check if a prefix could potentially form a valid word
  bool isPotentialWord(String prefix) {
    return _trie.startsWith(prefix.toUpperCase());
  }
  
  /// Get all words that can be formed with the given letters
  List<String> getPossibleWords(List<String> letters, GameDifficulty difficulty) {
    if (!_isInitialized) {
      throw Exception('Dictionary not initialized! Call initialize() first.');
    }
    
    final result = <String>[];
    
    // Create a map of letter frequencies
    final Map<String, int> letterCounts = {};
    for (final letter in letters) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }
    
    // Check each word in the dictionary - artık zorluk seviyesine göre filtreleme yok
    for (final word in _dictionary) {
      // Minimum 3 harfli kelimeler
      if (word.length < 3) {
        continue;
      }
      
      if (canFormWord(word, Map<String, int>.from(letterCounts))) {
        result.add(word);
      }
    }
    
    return result;
  }
  
  /// Check if a word can be formed with the given letter counts
  bool canFormWord(String word, Map<String, int> letterCounts) {
    final Map<String, int> tempCounts = Map<String, int>.from(letterCounts);
    
    for (int i = 0; i < word.length; i++) {
      final letter = word[i];
      if ((tempCounts[letter] ?? 0) <= 0) {
        return false;
      }
      tempCounts[letter] = tempCounts[letter]! - 1;
    }
    return true;
  }
  
  /// Check if JSON string is encrypted
  bool _isJsonEncrypted(String jsonString) {
    try {
      // Try to parse as JSON - if it fails, it might be encrypted
      json.decode(jsonString);
      return false;
    } catch (e) {
      return true;
    }
  }
  
  /// Encrypt the dictionary data
  static String encryptData(String jsonData) {
    final key = encrypt.Key(Uint8List.fromList(
      sha256.convert(utf8.encode(_encryptionKey)).bytes.take(32).toList()
    ));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    final encrypted = encrypter.encrypt(jsonData, iv: iv);
    return encrypted.base64;
  }
  
  /// Decrypt the dictionary data
  String _decryptData(String encryptedData) {
    final key = encrypt.Key(Uint8List.fromList(
      sha256.convert(utf8.encode(_encryptionKey)).bytes.take(32).toList()
    ));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
    return decrypted;
  }
  
  /// Utility method to encrypt the dictionary file (run this locally before pushing to GitHub)
  static Future<void> encryptDictionaryFile() async {
    try {
      final String jsonData = await rootBundle.loadString(_dictPath);
      
      // Skip if already encrypted
      if (_instance._isJsonEncrypted(jsonData)) {
        print('Dictionary file is already encrypted.');
        return;
      }
      
      final String encryptedData = encryptData(jsonData);
      
      // Log the encrypted data
      print('Encrypted dictionary data: $encryptedData');
      print('Please save this to $_dictPath');
      
      // Note: In a real app, you would write this back to a file
      // But Flutter can't write to assets at runtime
      // You need to manually replace the file content
    } catch (e) {
      print('Error encrypting dictionary: $e');
    }
  }
}