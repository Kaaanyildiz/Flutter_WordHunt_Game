import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';

/// Kelime veritabanını şifrelemek için basit bir araç
/// Bu araç, Flutter SDK'dan bağımsız olarak çalışır
void main() async {
  print('Kelime veritabanı şifreleme aracı başlatılıyor...');
  
  // Proje kök dizinini bul
  final projectRoot = Directory.current.path;
  final assetPath = path.join(projectRoot, 'assets', 'words_lib.json');
  final backupPath = path.join(projectRoot, 'assets', 'words_lib_original.json');
  final encryptedPath = path.join(projectRoot, 'assets', 'words_lib_encrypted.json');
  
  try {
    // Dosya var mı kontrol et
    final file = File(assetPath);
    if (!await file.exists()) {
      print('HATA: $assetPath bulunamadı!');
      return;
    }
    
    // JSON dosyasını oku
    final String jsonString = await file.readAsString();
    print('Kelime veritabanı başarıyla okundu.');
    
    // Yedek oluştur
    await File(backupPath).writeAsString(jsonString);
    print('Orijinal dosya yedeklendi: $backupPath');
    
    try {
      // JSON formatını doğrula
      final List<dynamic> words = json.decode(jsonString);
      print('Toplam ${words.length} kelime bulundu.');
      
      // Şifrele
      final String encryptedData = encryptData(jsonString);
      print('Kelime veritabanı başarıyla şifrelendi.');
      
      // Şifrelenmiş veriyi kaydet
      await File(encryptedPath).writeAsString(encryptedData);
      print('Şifrelenmiş veri $encryptedPath konumuna kaydedildi.');
      
      // Şifrelenmiş dosyayı ana konuma kopyala
      await File(encryptedPath).copy(assetPath);
      print('Şifrelenmiş veri ana kelime veritabanı konumuna kopyalandı: $assetPath');
      
      print('İşlem başarıyla tamamlandı. Artık dosyalarınızı commit edebilirsiniz.');
    } catch (e) {
      print('HATA: JSON ayrıştırma hatası - $e');
    }
  } catch (e) {
    print('HATA: Dosya okuma/yazma işlemi başarısız - $e');
  }
}

/// Veriyi şifrele
String encryptData(String jsonData) {
  final String encryptionKey = 'word_hunter_secret_key_2025';
  
  final key = encrypt.Key(Uint8List.fromList(
    sha256.convert(utf8.encode(encryptionKey)).bytes.take(32).toList()
  ));
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  
  final encrypted = encrypter.encrypt(jsonData, iv: iv);
  return encrypted.base64;
}