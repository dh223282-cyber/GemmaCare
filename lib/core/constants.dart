class AppConstants {
  static const String appName = 'GemmaCare';
  
  // Storage Keys
  static const String userDocInfo = 'userDocInfo';
  
  // API Config
  // Use http://10.0.2.2:11434 for Android emulator connecting to host localhost
  // Use http://localhost:11434 for iOS simulator or web
  static const String ollamaBaseUrl = 'http://10.0.2.2:11434/api/generate';
  static const String ollamaModel = 'gemma:4b'; // Assuming they have Gemma 4B installed
}
