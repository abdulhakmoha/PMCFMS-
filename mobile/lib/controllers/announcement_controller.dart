import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';

class AnnouncementController extends GetxController {
  var isLoading = false.obs;
  var announcements = <dynamic>[].obs;
  var isSubmitting = false.obs;

  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get('/announcements');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        announcements.value = data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching announcements: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAnnouncement(Map<String, dynamic> data) async {
    try {
      isSubmitting.value = true;
      final response = await ApiService.post('/announcements', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAnnouncements();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating announcement: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try {
      final response = await ApiService.delete('/announcements/$id');
      if (response.statusCode == 200) {
        await fetchAnnouncements();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
