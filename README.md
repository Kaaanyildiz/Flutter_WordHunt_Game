# Kelime Avı

<div align="center">

![Kelime Avı Logo](https://img.shields.io/badge/Kelime%20Avı-Türkçe%20Kelime%20Oyunu-6A5AE0?style=for-the-badge&logo=flutter)

[![Flutter](https://img.shields.io/badge/Flutter-2.0+-02569B?style=flat-square&logo=flutter)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Türkçe](https://img.shields.io/badge/Dil-Türkçe-red.svg?style=flat-square)](README.md)

**Harflerden anlamlı kelimeler oluştur ve puanları topla!**

<img src="![Image](https://github.com/user-attachments/assets/05624b64-9ac1-4b3f-afe6-fa707c099661)" alt="Kelime Avı Ekran Görüntüsü" width="600px"/>

</div>

## 📖 Hakkında

Kelime Avı, 4x4 harf tablosunda Türkçe kelimeler bulma üzerine kurulu eğlenceli bir kelime bulmaca oyunudur. Oyun hem kelime haznenizi geliştirmenize yardımcı olur hem de eğlenceli vakit geçirmenizi sağlar.

### ✨ Özellikler

- **Türkçe Kelime Veritabanı**: Geniş Türkçe kelime veritabanı ile çok sayıda kelime keşfedin
- **Üç Zorluk Seviyesi**: Farklı süre limitlerinde oynayabileceğiniz Kolay, Orta ve Zor zorluk seviyeleri
- **Puan Sistemi**: Kelimenin uzunluğuna göre değişen puan sistemi ile rekabetçi oyun deneyimi
- **Modern Tasarım**: Kullanıcı dostu, göz alıcı arayüz tasarımı
- **Harf Frekans Dengesi**: Türkçe'deki harf frekanslarına göre dengeli harf dağılımı

## 🎮 Nasıl Oynanır

1. Zorluk seviyesi seçin (Kolay: 90 saniye, Orta: 60 saniye, Zor: 45 saniye)
2. 4x4 harf tablosundaki harfleri kullanarak anlamlı kelimeler oluşturun
3. En az 3 harfli kelimeler oluşturmalısınız
4. Kelimeleri oluşturmak için bitişik harflere sırayla dokunun
5. Ne kadar uzun kelime, o kadar çok puan!

### 📝 Puanlama Sistemi

- 3 harfli kelimeler: 3 puan
- 4 harfli kelimeler: 5 puan
- 5 harfli kelimeler: 8 puan
- 6+ harfli kelimeler: harf sayısı + 5 puan

## 🔧 Kurulum

### Gereksinimler

- Flutter 2.0+
- Dart 2.12+
- Android veya iOS cihaz/emülatör

### Adım Adım Kurulum

```bash
# Proje reposunu klonlayın
git clone https://github.com/Kaaanyildiz/word_hunter.git

# Proje klasörüne girin
cd word_hunter

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

## 🛠️ Teknik Detaylar

Kelime Avı oyunu modern Flutter geliştirme tekniklerine uygun olarak geliştirilmiştir:

- **Mimari**: Domain-Driven Design yaklaşımı
- **State Yönetimi**: StatefulWidget ve temel state yönetimi
- **Veri Yapıları**: Kelime kontrolü için Trie veri yapısı kullanımı
- **Animasyonlar**: Doğal ve akıcı kullanıcı deneyimi için özel animasyonlar
- **Responsif Tasarım**: Farklı ekran boyutlarına uyumlu arayüz

## 🔐 Güvenlik ve Şifreleme

Bu proje, kelime veritabanını korumak için bir şifreleme sistemi içerir:

### Kelime Veritabanı Şifreleme

Projedeki kelime veritabanı (`assets/words_lib.json`), kaynak kodunu paylaşırken koruma amacıyla AES şifrelemesi kullanılarak şifrelenmektedir. Bu, kelime veritabanının kolay bir şekilde kopyalanmasını önlemek için tasarlanmıştır.

### Geliştirici Notları

Eğer bu projeyi klonladıysanız ve geliştirmeye katkıda bulunmak istiyorsanız:

1. **Git Hook Kurulumu**: Otomatik şifreleme için PowerShell betiğini çalıştırın:
   ```powershell
   PowerShell -ExecutionPolicy Bypass -File setup_git_hooks.ps1
   ```
   Bu betik, her commit öncesinde kelime veritabanını otomatik olarak şifreleyecek bir Git hook'u yapılandıracaktır.

2. **Manuel Şifreleme**: Kelime veritabanını manuel olarak şifrelemek için:
   ```bash
   dart lib/tools/encrypt_dictionary.dart
   ```

3. **Şifreleme Desteği**: Şifreleme, `crypto` ve `encrypt` paketleri kullanılarak gerçekleştirilir.

> **Not**: Kelime veritabanının şifreli versiyonu GitHub'da bulunur. Uygulama çalışırken, `WordDictionaryService` sınıfı şifreyi otomatik olarak çözer.

## 🌟 Katkıda Bulunma

Katkılarınızı memnuniyetle karşılıyoruz! Projeye katkıda bulunmak için:

1. Bu depoyu forklayın
2. Kendi branch'inizi oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inize push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📱 Ekran Görüntüleri

<div align="center">
<table>
  <tr>
    <td><img src="https://via.placeholder.com/250x500.png?text=Ana+Menü" alt="Ana Menü"/></td>
    <td><img src="https://via.placeholder.com/250x500.png?text=Oyun+Ekranı" alt="Oyun Ekranı"/></td>
    <td><img src="https://via.placeholder.com/250x500.png?text=Sonuç+Ekranı" alt="Sonuç Ekranı"/></td>
  </tr>
</table>
</div>

## 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır - ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.

## 👨‍💻 Geliştirici

- **Mehmet Kaan YILDIZ** - [GitHub](https://github.com/Kaaanyildiz) - [LinkedIn](www.linkedin.com/in/kaanyıldız1)

## 🙏 Teşekkürler

- [Flutter](https://flutter.dev/) ekibine harika bir framework sağladıkları için
- Tüm açık kaynak topluluğuna

---

<div align="center">
  <sub>Flutter ile ❤️ ile geliştirildi</sub>
</div>
