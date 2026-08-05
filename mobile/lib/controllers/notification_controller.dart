import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class NotificationController extends GetxController {
  var notifications = [].obs;
  var isLoading = false.obs;
  var hasUnread = false.obs;

  int get unreadCount => notifications.where((n) => n['read'] == false).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get(ApiConstants.notifications);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        notifications.value = data['data'] ?? data;
        hasUnread.value = unreadCount > 0;
      }
    } catch (e) {
      // silently fail
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllRead() async {
    try {
      await ApiService.put('${ApiConstants.notifications}/read-all', {});
      for (var n in notifications) {
        n['read'] = true;
      }
      notifications.refresh();
      hasUnread.value = false;
    } catch (e) {
      // silently fail
    }
  }

  Future<bool> notifyMeetingAttendees(String meetingId) async {
    try {
      final response = await ApiService.post('${ApiConstants.notifications}/meeting/$meetingId', {});
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Notifications sent to all attendees');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Could not send notifications');
      return false;
    }
  }
}
