import 'package:shared_preferences/shared_preferences.dart';

class CityStorage {
  static const String keyCity = 'city';

  static Future<void> saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCity, city);
  }

  static Future<String?> loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyCity);
  }

  static Future<void> clearCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCity);
  }
}
