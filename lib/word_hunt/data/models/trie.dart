/// Trie veri yapısı, kelime ön ekleri (prefix) için etkili arama yapıyı sağlar
class Trie {
  final Map<String, Trie> _children = {};
  bool _isEndOfWord = false;

  /// Trie yapısına yeni bir kelime ekler
  void insert(String word) {
    Trie current = this;
    
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      current._children.putIfAbsent(char, () => Trie());
      current = current._children[char]!;
    }
    
    current._isEndOfWord = true;
  }

  /// Trie yapısında bir kelimenin var olup olmadığını kontrol eder
  bool search(String word) {
    Trie? node = _searchNode(word);
    return node != null && node._isEndOfWord;
  }

  /// Verilen önek ile başlayan en az bir kelime olup olmadığını kontrol eder
  bool startsWith(String prefix) {
    return _searchNode(prefix) != null;
  }

  /// Verilen kelime veya öneki işaret eden düğümü bulur
  Trie? _searchNode(String word) {
    Trie current = this;
    
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      Trie? node = current._children[char];
      if (node == null) {
        return null;
      }
      current = node;
    }
    
    return current;
  }
}