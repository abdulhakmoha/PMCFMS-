import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class UserController extends GetxController {
  var isLoading = false.obs;
  var usersList = [].obs;
  var searchQuery = ''.obs;

  List<dynamic> get filteredUsers {
    if (searchQuery.value.isEmpty) return usersList;
    final q = searchQuery.value.toLowerCase();
    return usersList.where((u) =>
      (u['name'] ?? '').toString().toLowerCase().contains(q) ||
      (u['email'] ?? '').toString().toLowerCase().contains(q) ||
      (u['district'] ?? '').toString().toLowerCase().contains(q)
    ).toList();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get(ApiConstants.users);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        usersList.value = data['data'] ?? data;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    try {
      final response = await ApiService.put('${ApiConstants.users}/$userId/role', {'role': role});
      if (response.statusCode == 200) {
        await fetchUsers();
        Get.snackbar('Success', 'Role updated');
        return true;
      }
      final data = jsonDecode(response.body);
      Get.snackbar('Error', data['message'] ?? 'Failed to update role');
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await ApiService.delete('${ApiConstants.users}/$userId');
      if (response.statusCode == 200) {
        usersList.removeWhere((u) => u['_id'] == userId);
        Get.snackbar('Success', 'User deleted');
        return true;
      }
      final data = jsonDecode(response.body);
      Get.snackbar('Error', data['message'] ?? 'Failed to delete user');
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      return false;
    }
  }
}
