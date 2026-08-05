import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var user = {}.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userDataString = prefs.getString('user');

    if (token != null && userDataString != null) {
      isAuthenticated.value = true;
      user.value = jsonDecode(userDataString);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await ApiService.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        data.remove('token');
        await prefs.setString('user', jsonEncode(data));

        user.value = data;
        isAuthenticated.value = true;

        return true;
      } else {
        Get.snackbar('Error', data['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String name, String email, String password, String phone, String district) async {
    try {
      isLoading.value = true;
      final response = await ApiService.post(ApiConstants.register, {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'district': district,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        data.remove('token');
        await prefs.setString('user', jsonEncode(data));

        user.value = data;
        isAuthenticated.value = true;

        return true;
      } else {
        Get.snackbar('Error', data['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      isLoading.value = true;
      final response = await ApiService.put(ApiConstants.userProfile, profileData);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final updatedUser = data['data'] ?? data;
        user.value = updatedUser;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(updatedUser));

        Get.snackbar('Success', 'Profile updated successfully');
        return true;
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void updateUserLocal(Map<String, dynamic> userData) {
    user.value = userData;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user', jsonEncode(userData));
    });
  }

  Future<bool> uploadProfileImage(String filePath) async {
    try {
      isLoading.value = true;
      final response = await ApiService.putFormData(
        ApiConstants.userProfile,
        {},
        [MapEntry('profileImage', filePath)],
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = data['data'] ?? data;
        user.value = updatedUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(updatedUser));
        Get.snackbar('Success', 'Profile picture updated');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Could not upload image');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    isAuthenticated.value = false;
    user.value = {};
  }
}
