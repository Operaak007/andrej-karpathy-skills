// ignore_for_file: dead_code, unnecessary_type_check

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc(this._apiService) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    // Load saved token on initialization
    loadSavedToken();
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.postForm(
        '/login',
        body: {'email': event.email, 'password': event.password},
      );

      print('Login Response: $response'); // Debug log

      // Handle nested response structure
      Map<String, dynamic> data;

      if (response.containsKey('data') &&
          response['data'] is Map<String, dynamic>) {
        data = response['data'] as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        data = response;
      } else {
        throw Exception('Invalid response format: ${response.runtimeType}');
      }

      // Safely extract token with multiple format handling
      String token;
      final tokenValue = data['token'];

      print(
        'Token value: $tokenValue, Type: ${tokenValue.runtimeType}',
      ); // Debug log

      if (tokenValue == null) {
        // Try alternative key names
        final alternativeToken =
            data['access_token'] ?? data['accessToken'] ?? data['auth_token'];
        if (alternativeToken != null) {
          token = _extractToken(alternativeToken);
        } else {
          throw Exception('No token found in response: $data');
        }
      } else {
        token = _extractToken(tokenValue);
      }

      if (token.isEmpty) {
        throw Exception('Token is empty');
      }

      // Safely extract user data
      final user = data['user'] ?? data['userData'] ?? data['profile'];
      if (user == null) {
        throw Exception('No user data found in response');
      }

      final Map<String, dynamic> userMap;
      if (user is Map<String, dynamic>) {
        userMap = user;
      } else {
        // Try to convert to map if possible
        try {
          userMap = user as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Invalid user data format: ${user.runtimeType}');
        }
      }

      // Safely extract balance
      int balance = 0;
      if (data.containsKey('balance')) {
        balance = _parseBalance(data['balance']);
      } else if (data.containsKey('points')) {
        balance = _parseBalance(data['points']);
      }

      _apiService.setToken(token);
      await _saveToken(token);

      emit(Authenticated(token: token, user: userMap, balance: balance));
    } on ApiException catch (e) {
      print('Login ApiException: ${e.message}'); // Debug log
      emit(AuthError(e.message));
    } catch (e) {
      print('Login error: $e'); // Debug log
      emit(AuthError(e.toString()));
    }
  }

  // Helper method to extract token from various formats
  String _extractToken(dynamic tokenValue) {
    if (tokenValue == null) {
      throw Exception('Token value is null');
    }

    // If it's already a String
    if (tokenValue is String) {
      return tokenValue;
    }

    // If it's a Map (nested token)
    if (tokenValue is Map<String, dynamic>) {
      // Try common nested token keys
      final nestedToken =
          tokenValue['token'] ??
          tokenValue['access_token'] ??
          tokenValue['accessToken'] ??
          tokenValue['value'];

      if (nestedToken is String) {
        return nestedToken;
      }

      // If the map has a 'data' key
      if (tokenValue.containsKey('data')) {
        return _extractToken(tokenValue['data']);
      }
    }

    // If it's a List
    if (tokenValue is List) {
      if (tokenValue.isNotEmpty) {
        return _extractToken(tokenValue.first);
      }
      throw Exception('Token list is empty');
    }

    // If it's a number, convert to string
    if (tokenValue is num) {
      return tokenValue.toString();
    }

    // If it's a boolean
    if (tokenValue is bool) {
      return tokenValue ? 'true' : 'false';
    }

    // Try JSON string
    if (tokenValue is String) {
      try {
        final decoded = json.decode(tokenValue);
        if (decoded is Map<String, dynamic>) {
          return _extractToken(decoded);
        }
        return tokenValue;
      } catch (_) {
        return tokenValue;
      }
    }

    throw Exception('Unsupported token format: ${tokenValue.runtimeType}');
  }

  // Helper method to parse balance from various formats
  int _parseBalance(dynamic balanceValue) {
    if (balanceValue == null) return 0;

    if (balanceValue is int) return balanceValue;
    if (balanceValue is double) return balanceValue.toInt();
    if (balanceValue is String) {
      final parsed = double.tryParse(balanceValue);
      return parsed?.toInt() ?? 0;
    }
    if (balanceValue is num) return balanceValue.toInt();
    if (balanceValue is Map) {
      // Try to extract from map
      final value =
          balanceValue['value'] ??
          balanceValue['amount'] ??
          balanceValue['points'];
      return _parseBalance(value);
    }

    return 0;
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.post(
        '/register',
        body: {
          'name': event.name,
          'email': event.email,
          'password': event.password,
          'phone': event.phone,
        },
      );

      print('Register Response: $response'); // Debug log

      // Check if registration was successful
      if (response.containsKey('success') && response['success'] == false) {
        final errorMessage =
            response['message'] as String? ?? 'Registration failed';
        emit(AuthError(errorMessage));
        return;
      }

      emit(AuthInitial());
      // Auto-login after registration
      add(LoginRequested(email: event.email, password: event.password));
    } on ApiException catch (e) {
      print('Register ApiException: ${e.message}'); // Debug log
      emit(AuthError(e.message));
    } catch (e) {
      print('Register error: $e'); // Debug log
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _apiService.post('/logout');
    } catch (_) {
      // Ignore logout errors
    }

    _apiService.setToken(null);
    await _clearToken();
    emit(Unauthenticated());
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.post(
        '/forgot-password',
        body: {'email': event.email},
      );

      print('Forgot Password Response: $response'); // Debug log

      // Handle nested response structure
      String message = 'Reset instructions sent';

      if (response.containsKey('data') &&
          response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;
        if (data.containsKey('message') && data['message'] is String) {
          message = data['message'] as String;
        }
      } else if (response.containsKey('message') &&
          response['message'] is String) {
        message = response['message'] as String;
      }

      emit(PasswordResetSent(message));
    } on ApiException catch (e) {
      print('Forgot password ApiException: ${e.message}'); // Debug log
      emit(AuthError(e.message));
    } catch (e) {
      print('Forgot password error: $e'); // Debug log
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.post(
        '/reset-password',
        body: {
          'email': event.email,
          'token': event.token,
          'password': event.newPassword,
        },
      );

      print('Reset Password Response: $response'); // Debug log

      // Check if reset was successful
      if (response.containsKey('success') && response['success'] == false) {
        final errorMessage =
            response['message'] as String? ?? 'Password reset failed';
        emit(AuthError(errorMessage));
        return;
      }

      emit(const PasswordResetSent('Password reset successful'));
    } on ApiException catch (e) {
      print('Reset password ApiException: ${e.message}'); // Debug log
      emit(AuthError(e.message));
    } catch (e) {
      print('Reset password error: $e'); // Debug log
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  Future<void> loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        _apiService.setToken(token);
        // Emit authenticated state with stored token
        emit(Authenticated(token: token, user: const {}, balance: 0));
      }
    } catch (e) {
      print('Error loading saved token: $e');
    }
  }
}
