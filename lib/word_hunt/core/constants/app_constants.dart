class AppConstants {
  // Uygulama bilgileri
  static const String appName = 'Kelime Avı';
  
  // Rota bilgileri
  static const String homeRoute = '/';
  static const String wordHuntRoute = '/word-hunt';
  
  // Word Hunt ile ilgili sabitler
  static const int wordHuntMinimumWordLength = 3;
  static const int wordHuntEasyTimeLimit = 90;
  static const int wordHuntMediumTimeLimit = 60;
  static const int wordHuntHardTimeLimit = 45;
}

/// Supported languages
class AppLanguage {
  final String code;
  final String name;

  const AppLanguage(this.code, this.name);

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage('tr', 'Türkçe'),
    AppLanguage('en', 'English'),
  ];
}

/// App theme modes
enum AppThemeMode {
  light,
  dark,
  system,
}