import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';

class IssueController extends GetxController {
  var isLoading = false.obs;
  var issues = <dynamic>[].obs;
  var isSubmitting = false.obs;

  Future<void> fetchIssues() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get('/issues');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        issues.value = data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching issues: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createIssue(Map<String, dynamic> data) async {
    try {
      isSubmitting.value = true;
      final response = await ApiService.post('/issues', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchIssues();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating issue: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateIssueStatus(String id, String status, {String? adminNotes}) async {
    try {
      final body = <String, dynamic>{'status': status};
      if (adminNotes != null && adminNotes.isNotEmpty) {
        body['adminNotes'] = adminNotes;
      }
      final response = await ApiService.put('/issues/$id/status', body);
      if (response.statusCode == 200) {
        final updated = jsonDecode(response.body)['data'];
        final idx = issues.indexWhere((i) => i['_id'] == id);
        if (idx != -1) issues[idx] = updated;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> addComment(String issueId, String text) async {
    try {
      final response = await ApiService.post('/issues/$issueId/comments', {'text': text});
      if (response.statusCode == 200) {
        final updated = jsonDecode(response.body)['data'];
        final idx = issues.indexWhere((i) => i['_id'] == issueId);
        if (idx != -1) issues[idx] = updated;
        return updated;
      }
    } catch (e) {
      print('Error adding comment: $e');
    }
    return null;
  }

  Future<bool> deleteIssue(String id) async {
    try {
      final response = await ApiService.delete('/issues/$id');
      if (response.statusCode == 200) {
        issues.removeWhere((i) => i['_id'] == id);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting issue: $e');
      return false;
    }
  }
}
