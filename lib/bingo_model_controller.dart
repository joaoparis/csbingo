import 'package:flutter/material.dart';

class BingoModelController extends ChangeNotifier {
  String _outputText = "Loading...";
  String _timerText = "00:00";
  String _scoreText = "0pts";
  String _buttonText = "PLAY";
  String _buttonStatus = "idle";

  String get outputText => _outputText;

  void setOutputText(String text) {
    if (_outputText != text) {
      _outputText = text;
      notifyListeners();
    }
  }
}
