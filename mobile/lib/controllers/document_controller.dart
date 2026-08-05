import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';

class DocumentController extends GetxController {
  var isLoading = false.obs;
  var documents = <dynamic>[].obs;
  var isUploading = false.obs;

  Future<void> fetchDocuments() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get('/documents');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        documents.value = data['data'] ?? [];
      }
    } catch (e) {
      print('Error fetching documents: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadDocument(Map<String, dynamic> data) async {
    try {
      isUploading.value = true;
      final response = await ApiService.post('/documents', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchDocuments();
        return true;
      }
      return false;
    } catch (e) {
      print('Error uploading document: $e');
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      final response = await ApiService.delete('/documents/$id');
      if (response.statusCode == 200) {
        await fetchDocuments();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
