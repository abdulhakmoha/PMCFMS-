import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/document_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/api_constants.dart';
import '../../utils/theme.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentController controller = Get.put(DocumentController());
  final AuthController authController = Get.find<AuthController>();
  String _category = 'all';
  String? _error;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    controller.fetchDocuments();
  }

  bool get _canManage => authController.user['role'] == 'admin' || authController.user['role'] == 'moderator';

  List<dynamic> get _filtered {
    if (_category == 'all') return controller.documents;
    return controller.documents.where((d) => (d['category'] ?? '').toString().toLowerCase() == _category.toLowerCase()).toList();
  }

  Color _catColor(String? cat) {
    switch (cat) {
      case 'Budget': return const Color(0xFF10B981);
      case 'Minutes': return const Color(0xFF10B981);
      case 'Policy': return const Color(0xFFF59E0B);
      default: return const Color(0xFF64748B);
    }
  }

  Color _catBg(String? cat) {
    return _catColor(cat).withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Document Library'),
        actions: [
          if (_canManage)
            IconButton(
              icon: const Icon(Icons.upload_file, color: AppTheme.primaryColor),
              onPressed: () => _showUploadSheet(),
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _catChip('all', 'All'),
                const SizedBox(width: 8),
                _catChip('budget', 'Budget'),
                const SizedBox(width: 8),
                _catChip('minutes', 'Minutes'),
                const SizedBox(width: 8),
                _catChip('policy', 'Policy'),
                const SizedBox(width: 8),
                _catChip('other', 'Other'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              final items = _filtered;
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.folder_open, size: 36, color: AppTheme.textSubtle),
                      ),
                      const SizedBox(height: 16),
                      const Text('No documents uploaded yet.', style: TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontCardTitle)),
                      const SizedBox(height: 4),
                      const Text('Documents will appear here once they are added.', style: TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchDocuments(),
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildCard(items[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _catChip(String value, String label) {
    final active = _category == value;
    return GestureDetector(
      onTap: () => setState(() => _category = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? AppTheme.primaryColor : AppTheme.borderColor),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : AppTheme.textMuted, fontSize: AppTheme.fontMeta, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildCard(dynamic doc) {
    final cat = doc['category'] ?? 'Other';
    final color = _catColor(cat);
    final url = doc['fileUrl'] ?? doc['url'] ?? '';
    final fullUrl = url.startsWith('http') ? url : '${ApiConstants.baseUrl}$url';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, width: double.infinity, color: color),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: _catBg(cat), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.description_outlined, color: color, size: 18),
                      ),
                      const Spacer(),
                      if (_canManage)
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert, color: AppTheme.textSubtle, size: 16),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: const Row(children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ]),
                            ),
                          ],
                          onSelected: (v) async {
                            if (v == 'delete') await controller.deleteDocument(doc['_id']);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _catBg(cat), borderRadius: BorderRadius.circular(6)),
                    child: Text(cat, style: TextStyle(color: color, fontSize: AppTheme.fontSmall - 1, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    doc['title'] ?? 'Untitled',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontBody, fontWeight: FontWeight.bold),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  if (doc['description'] != null && (doc['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      doc['description'],
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontSmall),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.borderColor, width: 0.5))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (doc['createdAt'] != null)
                                Text(
                                  DateFormat('MMM d, yyyy').format(DateTime.parse(doc['createdAt'])),
                                  style: const TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall - 1),
                                ),
                              if (doc['fileSize'] != null)
                                Text(
                                  'Size: ${doc['fileSize']}',
                                  style: const TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall - 1),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openDocument(fullUrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download, color: Colors.white, size: 12),
                                SizedBox(width: 3),
                                Text('Download', style: TextStyle(color: Colors.white, fontSize: AppTheme.fontSmall - 1, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Cannot open document');
    }
  }

  void _showUploadSheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Policy';
    PlatformFile? selectedFile;
    _error = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Container(
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)),
                ),
                Container(height: 4, width: double.infinity, color: const Color(0xFF10B981)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present, size: 20, color: Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      const Text('Upload New Document', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: AppTheme.fontSmall, fontWeight: FontWeight.w600)),
                        ),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Document Title',
                          hintText: 'e.g. Banadir District Budget 2026',
                          filled: true, fillColor: AppTheme.backgroundColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          filled: true, fillColor: AppTheme.backgroundColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Policy', child: Text('Policy')),
                          DropdownMenuItem(value: 'Budget', child: Text('Budget')),
                          DropdownMenuItem(value: 'Minutes', child: Text('Minutes')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setDialogState(() => category = v ?? 'Policy'),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );
                          if (result != null && result.files.isNotEmpty) {
                            setDialogState(() {
                              selectedFile = result.files.first;
                              if (titleCtrl.text.isEmpty) {
                                titleCtrl.text = selectedFile!.name.replaceAll(RegExp(r'\.[^/.]+$'), '');
                              }
                              _error = null;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedFile != null ? AppTheme.primaryColor.withValues(alpha: 0.08) : AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedFile != null ? AppTheme.primaryColor : AppTheme.borderColor,
                              width: selectedFile != null ? 1.5 : 1,
                              style: selectedFile != null ? BorderStyle.solid : BorderStyle.solid,
                            ),
                          ),
                          child: selectedFile != null
                              ? Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(selectedFile!.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontBody), overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${(selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                                            style: const TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  children: [
                                    Icon(Icons.cloud_upload_outlined, size: 32, color: AppTheme.textSubtle),
                                    SizedBox(height: 8),
                                    Text('Tap to upload PDF', style: TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontBody)),
                                    SizedBox(height: 2),
                                    Text('PDF files only', style: TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Brief description of this document...',
                          filled: true, fillColor: AppTheme.backgroundColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _uploading
                              ? null
                              : () async {
                                  if (titleCtrl.text.isEmpty) {
                                    setDialogState(() => _error = 'Document title is required');
                                    return;
                                  }
                                  if (selectedFile == null) {
                                    setDialogState(() => _error = 'Please select a PDF file');
                                    return;
                                  }
                                  setDialogState(() => _error = null);
                                  setDialogState(() => _uploading = true);
                                  final uploadUrl = await ApiService.uploadPlatformFile(selectedFile!);
                                  if (uploadUrl == null) {
                                    setDialogState(() {
                                      _error = 'Failed to upload file';
                                      _uploading = false;
                                    });
                                    return;
                                  }
                                  final sizeStr = selectedFile!.size < 1024 * 1024
                                      ? '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB'
                                      : '${(selectedFile!.size / (1024 * 1024)).toStringAsFixed(1)} MB';
                                  final success = await controller.uploadDocument({
                                    'title': titleCtrl.text.trim(),
                                    'description': descCtrl.text.trim(),
                                    'fileUrl': uploadUrl,
                                    'fileSize': sizeStr,
                                    'category': category,
                                  });
                                  setDialogState(() => _uploading = false);
                                  if (success) {
                                    Navigator.pop(context);
                                    Get.snackbar('Success', 'Document uploaded successfully');
                                  } else {
                                    setDialogState(() => _error = 'Failed to save document');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _uploading ? 'Saving & Uploading...' : 'Save Document',
                            style: const TextStyle(fontSize: AppTheme.fontBody, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
