import 'package:flutter/material.dart';

class ModeProvider extends ChangeNotifier {
  bool _isOnlineMode = false;
  bool get isOnlineMode => _isOnlineMode;

  void toggleMode() {
    _isOnlineMode = !_isOnlineMode;
    notifyListeners();
  }
}
