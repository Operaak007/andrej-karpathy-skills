// ignore_for_file: unused_field

class ApiConfig {
  // Change this to your server URL 10.145.253.247
  static const String baseUrl = 'http://10.126.218.138:8000/api/v1';

  // For physical device testing, use your computer's IP address:
  // static const String baseUrl = 'http://192.168.x.x:8080/api/v1'; 192.168.100.134

  static const Duration timeout = Duration(seconds: 20);
}
