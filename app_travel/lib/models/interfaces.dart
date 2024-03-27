import 'package:flutter/material.dart';

class UserInterface with ChangeNotifier {
  static List<String> listColorAppBar = <String>['Grey', 'Purple', 'Red', 'Green', 'Blue'];

  double _fontSize = 20;
  Color _icon = Colors.purple;
  String _appBarColor = 'Grey';


  set appBarColor(newColor) {
    _appBarColor = newColor;
    notifyListeners();
  }

  Color get appBarColor {
    switch(_appBarColor) {
      case 'Grey': return Color(0xFF475269);
      case 'Purple': return Colors.purple;
      case 'Red': return Colors.red;
      case 'Green': return Colors.green;
      case 'Blue': return Colors.blue;
      default: return Color(0xFF475269);
    }
  }

  String get strAppBarColor => _appBarColor;

  set iconColor(newColor){
    _icon = newColor;
    notifyListeners();
  }
  Color get iconColor{
    return _icon;
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }


  set fontSize(newSize) {
    _fontSize = newSize;
    notifyListeners();
  }

  double get fontSize {
    return _fontSize;
  }

  void resetSettings() {
    _themeMode = ThemeMode.system;
    _appBarColor = "Grey";
    notifyListeners();
  }

}

