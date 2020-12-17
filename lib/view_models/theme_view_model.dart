import 'package:atsign_location_app/data_services/hive/hive_db.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'base_model.dart';

class ThemeProvider extends BaseModel {
  ThemeColor themeColor;
  HiveDataProvider _hiveDataProvider;
  bool isDark = false;

  ThemeProvider({this.themeColor}) {
    _hiveDataProvider = HiveDataProvider();
    checkTheme();
  }

  checkTheme() async {
    ThemeColor _currentTheme;
    var res = await _hiveDataProvider.readData('theme');

    if (res['theme_color'] == 'ThemeColor.Dark') {
      _currentTheme = ThemeColor.Dark;
      isDark = true;
    } else {
      isDark = false;
      _currentTheme = ThemeColor.Light;
    }

    return _currentTheme;
  }

  setTheme(ThemeColor themeColor) async {
    await Hive.initFlutter();
    await _hiveDataProvider
        .insertData('theme', {'theme_color': themeColor.toString()});

    this.themeColor = themeColor;
    isDark = themeColor == ThemeColor.Dark ? true : false;

    notifyListeners();
  }

  ThemeColor get getTheme => themeColor;
}

enum ThemeColor { Light, Dark }
