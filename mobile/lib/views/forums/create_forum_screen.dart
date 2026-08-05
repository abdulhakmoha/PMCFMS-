import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/forum_controller.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class CreateForumScreen extends StatefulWidget {
  const CreateForumScreen({Key? key}) : super(key: key);
  @override
  State<CreateForumScreen> createState() => _CreateForumScreenState();
}

class _CreateForumScreenState extends State<CreateForumScreen> {
  final ForumController controller = Get.find<ForumController>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'General';
  List<String> _imageUrls = [];
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handlePickImages() async {
    final result = await FilePicker.pickFiles(type: FileType.image, allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _uploading = true);
      for (final file in result.files) {
        final url = await ApiService.uploadPlatformFile(file);
        if (url != null) _imageUrls.add(url);
      }
      setState(() => _uploading = false);
    }
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await controller.createForum({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _category,
      if (_imageUrls.isNotEmpty) 'images': _imageUrls,
    });
    if (success) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Start Discussion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your topic will be reviewed by a moderator before it becomes visible to everyone.',
                        style: TextStyle(color: Colors.amber, fontSize: AppTheme.fontBody),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel('Topic Title'),
              _buildTextField(_titleController, 'What do you want to discuss?',
                  validator: (v) => v == null || v.isEmpty ? 'Title is required' : null),
              const SizedBox(height: 20),
              _buildLabel('Category'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    dropdownColor: AppTheme.surfaceColor,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'General', child: Text('General')),
                      DropdownMenuItem(value: 'Infrastructure', child: Text('Infrastructure')),
                      DropdownMenuItem(value: 'Education', child: Text('Education')),
                      DropdownMenuItem(value: 'Healthcare', child: Text('Healthcare')),
                      DropdownMenuItem(value: 'Security', child: Text('Security')),
                    ],
                    onChanged: (v) => setState(() => _category = v ?? 'General'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Details'),
              _buildTextField(_descController, 'Provide more context for the discussion...',
                  maxLines: 5, validator: (v) => v == null || v.isEmpty ? 'Description is required' : null),
              const SizedBox(height: 20),
              // Image Upload
              GestureDetector(
                onTap: _uploading ? null : _handlePickImages,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                    color: AppTheme.surfaceColor,
                  ),
                  child: _uploading
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : _imageUrls.isNotEmpty
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
                                    const SizedBox(width: 6),
                                    Text('${_imageUrls.length} image(s) attached', style: TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: _imageUrls.map((url) => Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppTheme.backgroundColor,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network('http://10.0.2.2:5001$url', fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(Icons.image, color: AppTheme.textSubtle)),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Icon(Icons.image_outlined, color: AppTheme.textSubtle, size: 32),
                                const SizedBox(height: 6),
                                Text('Attach Images (optional)', style: TextStyle(color: AppTheme.textSubtle, fontSize: 12)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 30),
              Obx(() => SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Post Topic', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSubtle),
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
