import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null || StorageService.getAccessToken() != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    checkAuthStatus();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize auth status from storage
  Future<void> checkAuthStatus() async {
    final cachedUser = StorageService.getUser();
    if (cachedUser != null) {
      _user = UserModel.fromJson(cachedUser);
    }
    _isInitialized = true;
    notifyListeners();

    if (StorageService.getAccessToken() != null) {
      // Refresh current user from server in background
      await fetchMe();
    }
  }

  /// Login with phone and password
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiEndpoints.login,
        body: {'phone': phone.trim(), 'password': password},
        requireAuth: false,
      );

      final userMap = response['user'] ?? response;
      final accessToken = response['accessToken'] ?? response['token'];
      final refreshToken = response['refreshToken'];

      if (accessToken != null) {
        await StorageService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        );
      }

      _user = UserModel.fromJson(userMap as Map<String, dynamic>);
      await StorageService.saveUser(_user!.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send OTP to phone
  Future<bool> sendOtp(String phone, {String purpose = 'register'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.post(
        ApiEndpoints.sendOtp,
        body: {'phone': phone.trim(), 'purpose': purpose},
        requireAuth: false,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code, returns otpToken on success
  Future<String?> verifyOtp(String phone, String otp, {String purpose = 'register'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiEndpoints.verifyOtp,
        body: {'phone': phone.trim(), 'otp': otp.trim(), 'purpose': purpose},
        requireAuth: false,
      );
      _isLoading = false;
      notifyListeners();

      if (response is Map<String, dynamic> && response['otpToken'] != null) {
        return response['otpToken'] as String;
      }
      return null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Register with verified OTP token
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    required String otpToken,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiEndpoints.register,
        body: {
          'name': name.trim(),
          'phone': phone.trim(),
          'password': password,
          'otpToken': otpToken,
        },
        requireAuth: false,
      );

      final userMap = response['user'] ?? response;
      final accessToken = response['accessToken'] ?? response['token'];
      final refreshToken = response['refreshToken'];

      if (accessToken != null) {
        await StorageService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        );
      }

      _user = UserModel.fromJson(userMap as Map<String, dynamic>);
      await StorageService.saveUser(_user!.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password using otpToken
  Future<bool> changePassword({
    required String newPassword,
    required String otpToken,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.post(
        ApiEndpoints.changePassword,
        body: {
          'newPassword': newPassword,
          'otpToken': otpToken,
        },
        requireAuth: false,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch logged in user profile
  Future<void> fetchMe() async {
    try {
      final response = await ApiService.get(ApiEndpoints.me);
      final userMap = response['user'] ?? response;
      if (userMap is Map<String, dynamic>) {
        _user = UserModel.fromJson(userMap);
        await StorageService.saveUser(_user!.toJson());
        notifyListeners();
      }
    } catch (_) {
      // Ignore background sync errors
    }
  }

  /// Update Landlord Name
  Future<bool> updateName(String newName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.put(
        ApiEndpoints.updateUser,
        body: {'name': newName.trim()},
      );
      final userMap = response['user'] ?? response;
      if (userMap is Map<String, dynamic>) {
        _user = UserModel.fromJson(userMap);
      } else if (_user != null) {
        _user = _user!.copyWith(name: newName.trim());
      }
      if (_user != null) {
        await StorageService.saveUser(_user!.toJson());
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final refreshToken = StorageService.getRefreshToken();
      if (refreshToken != null) {
        await ApiService.post(
          ApiEndpoints.logout,
          body: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Continue clearing local state even if logout request fails
    } finally {
      await StorageService.clearTokens();
      _user = null;
      notifyListeners();
    }
  }
}
