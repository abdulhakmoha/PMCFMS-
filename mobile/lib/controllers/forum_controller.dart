import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class ForumController extends GetxController {
  var isLoading = true.obs;
  var forumsList = [].obs;
  var currentForum = {}.obs;
  var forumComments = [].obs;
  var isDetailLoading = true.obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchForums();
  }

  Future<void> fetchForums() async {
    try {
      isLoading(true);
      final response = await ApiService.get(ApiConstants.forums);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        forumsList.value = data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching forums: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchForumDetails(String id) async {
    try {
      isDetailLoading(true);
      final response = await ApiService.get('${ApiConstants.forums}/$id');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentForum.value = data['data'] ?? {};
        forumComments.value = data['comments'] ?? [];
      }
    } catch (e) {
      print('Error fetching forum details: $e');
    } finally {
      isDetailLoading(false);
    }
  }

  Future<bool> createForum(Map<String, dynamic> forumData) async {
    try {
      final response = await ApiService.post(ApiConstants.forums, forumData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchForums();
        Get.snackbar('Success', 'Forum topic created');
        return true;
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to create');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      return false;
    }
  }

  Future<bool> voteForum(String id, String type) async {
    try {
      final response = await ApiService.put('${ApiConstants.forums}/$id/$type', {});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentForum.value = data['data'] ?? {};
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> postComment(String forumId, String text) async {
    try {
      isSubmitting(true);
      final response = await ApiService.post('${ApiConstants.forums}/$forumId/comments', {'text': text});
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchForumDetails(forumId);
        return true;
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to post');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not connect to server');
      return false;
    } finally {
      isSubmitting(false);
    }
  }

  Future<bool> approveForum(String id) async {
    try {
      final response = await ApiService.put('${ApiConstants.forums}/$id/approve', {});
      if (response.statusCode == 200) {
        await fetchForums();
        Get.snackbar('Success', 'Forum topic approved');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Could not approve forum');
      return false;
    }
  }

  Future<bool> deleteForum(String id) async {
    try {
      final response = await ApiService.delete('${ApiConstants.forums}/$id');
      if (response.statusCode == 200) {
        await fetchForums();
        Get.snackbar('Success', 'Forum topic deleted');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Could not delete forum');
      return false;
    }
  }
}
