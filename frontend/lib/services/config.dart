import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig{
  static String getBaseURL(){
    if (kIsWeb) {
      return "";
    } else if (Platform.isAndroid) {
      return "";
    } else {
      return "";
    }
  }
}