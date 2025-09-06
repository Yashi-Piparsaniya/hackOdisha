import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String getBaseURL() {
    if (kIsWeb) {
      return "http://localhost:5000";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:5000";
    } else if (Platform.isIOS) {
      return "http://localhost:5000";
    } else {
      return "http://localhost:5000";
    }
  }
}
