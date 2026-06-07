import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/network/api_service.dart';
import '../store/healix_store.dart';

class AuthService {
  final ApiService _api = ApiService();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // ── Singleton ──
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── Login ──────────────────────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // All logins now go through the real backend.
      // Demo accounts seeded: patient@demo.com / Demo@123  |  doctor@demo.com / Demo@123
      
      final response = await _api.post('/accounts/login', data: {
        'userNameOrEmail': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Step 1: Handle token response
        final tokenData = response.data; // AccessToken, RefreshToken, Expiration
        final String accessToken = tokenData['accessToken'];
        
        // Save token immediately for subsequent profile fetch
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, accessToken);

        // Step 2: Fetch full profile
        return await getProfile();
      } else {
        return AuthResult.failure("Login failed with status ${response.statusCode}");
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // ── Register ───────────────────────────────────────────────────────────
  Future<AuthResult> register({
    required String userName,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required int gender,
    required String address,
    String? specializationId, // For doctors
    String? licenseId, // For doctors
  }) async {
    try {
      final registerData = {
        'userName': userName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'person': {
          'firstName': firstName,
          'lastName': lastName,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'address': address,
        },
        if (role.toLowerCase() == 'doctor') ...{
          'specializationId': specializationId,
          'licenseId': licenseId,
        },
      };

      final String endpoint = role.toLowerCase() == 'doctor' 
          ? '/accounts/doctors/register' 
          : '/accounts/patients/register';

      final response = await _api.post(endpoint, data: registerData);

      if (response.statusCode == 200) {
        // Backend returns Ok(new { Message, ConfirmLink })
        // After registration, we usually ask user to login or we auto-login if backend supports it
        // For now, we'll suggest logging in since we don't have the token yet
        return AuthResult.success(UserModel(
          id: '0', 
          fullName: "$firstName $lastName", 
          email: email, 
          roles: [role]
        ));
      } else {
        return AuthResult.failure("Registration failed");
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // ── Get Profile ────────────────────────────────────────────────────────
  Future<AuthResult> getProfile() async {
    try {
      final response = await _api.get('/accounts/profile');
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        _currentUser = user;
        
        // Populate Global Store
        healixStore.userName.value = user.fullName;
        
        // Handle patient/doctor IDs from backend response.
        // Use loginAsPatient() so per-patient data isolation is triggered.
        final pId = response.data['patientId'] ?? response.data['PatientId'];
        if (pId != null) {
          await healixStore.loginAsPatient(pId.toString());
        }
        final dId = response.data['doctorId'] ?? response.data['DoctorId'];
        if (dId != null) {
          healixStore.doctorId.value = dId.toString();
        }

        await _saveSession(user);
        return AuthResult.success(user);
      }
      return AuthResult.failure("Could not fetch profile");
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _currentUser = null;
    healixStore.userName.value = 'User';
    healixStore.doctorId.value = null;
    // Clear all in-memory data and reset the patient scope.
    await healixStore.loginAsPatient(null);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // ── Restore session on app start ───────────────────────────────────────
  Future<UserModel?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final user = UserModel.fromJson(jsonDecode(userJson));
        _currentUser = user;
        // Optionally refresh profile in background
        getProfile();
        return user;
      }
    } catch (_) {}
    return null;
  }

  // ── Save session to local storage ──────────────────────────────────────
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.token != null) await prefs.setString(_tokenKey, user.token!);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // ── Get auth header for subsequent requests ────────────────────────────
  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

// ── Result wrapper ──────────────────────────────────────────────────────────
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(UserModel user) =>
      AuthResult._(isSuccess: true, user: user);

  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}

// Global instance
final authService = AuthService();
