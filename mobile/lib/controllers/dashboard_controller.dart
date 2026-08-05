import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;
  var statistics = {}.obs;
  var hasError = false.obs;

  int get totalUsers => statistics['totalUsers'] ?? 0;
  int get activeMeetings => statistics['activeMeetings'] ?? 0;
  int get openForums => statistics['openForums'] ?? 0;
  int get totalComments => statistics['totalComments'] ?? 0;
  List get recentActivity => statistics['recentActivity'] ?? [];
  Map get analytics => statistics['analytics'] ?? {};
  List get monthlyMeetings => analytics['monthlyMeetings'] ?? [];
  List get forumsByCategory => analytics['forumsByCategory'] ?? [];
  List get usersByDistrict => analytics['usersByDistrict'] ?? [];

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading(true);
      hasError(false);
      
      final response = await ApiService.get(ApiConstants.dashboard);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        statistics.value = data['data'] ?? data;
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
      print('Error fetching dashboard: $e');
    } finally {
      isLoading(false);
    }
  }
}
