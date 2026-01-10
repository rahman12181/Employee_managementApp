import 'package:flutter/material.dart';

class SlideProvider extends ChangeNotifier {
  bool _showSlideToPunch = false;
  bool _isPunchInMode = true;
  Function(bool)? _punchCallback;
  
  bool get showSlideToPunch => _showSlideToPunch;
  bool get isPunchInMode => _isPunchInMode;
  
  void showSlideButton(bool isPunchIn, Function(bool) punchCallback) {
    _showSlideToPunch = true;
    _isPunchInMode = isPunchIn;
    _punchCallback = punchCallback;
    notifyListeners();
  }
  
  void hideSlideButton() {
    _showSlideToPunch = false;
    _punchCallback = null;
    notifyListeners();
  }
  
  void completePunch() {
    if (_punchCallback != null) {
      _punchCallback!(_isPunchInMode);
    }
    hideSlideButton();
  }
}