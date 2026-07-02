// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class ApiConfig {
  // Change this to your server URL
  static const String baseUrl =
      'https://4652-102-91-92-54.ngrok-free.app/api/v1';

  // 'https://abc123xyz.ngrok-free.app/api/v1'

  // For physical device testing, use your computer's IP address:
  // static const String baseUrl = 'http://192.168.x.x:8080/api/v1'; 192.168.100.134

  static const Duration timeout = Duration(seconds: 30);
}
