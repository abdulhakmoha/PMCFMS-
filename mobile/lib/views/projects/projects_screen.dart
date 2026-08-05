import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/project_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/api_constants.dart';
import '../../utils/theme.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectController controller = Get.put(ProjectController());
  final AuthController authController = Get.find<AuthController>();
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    controller.fetchProjects();
  }

  bool get _canCreate => authController.user['role'] == 'admin' || authController.user['role'] == 'moderator';

  List<dynamic> get _filtered {
    if (_filter == 'all') return controller.projects;
    return controller.projects.where((p) => (p['status'] ?? '').toString().toLowerCase() == _filter.toLowerCase()).toList();
  }

  int _countByStatus(String status) {
    return controller.projects.where((p) => (p['status'] ?? '').toString().toLowerCase() == status.toLowerCase()).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Community Projects'),
        actions: [
          if (_canCreate)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              onPressed: () => _showCreateDialog(),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip('all', 'All'),
                const SizedBox(width: 8),
                _filterChip('Planning', 'Planning'),
                const SizedBox(width: 8),
                _filterChip('In Progress', 'Active'),
                const SizedBox(width: 8),
                _filterChip('Completed', 'Done'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              final items = _filtered;
              if (items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, size: 64, color: AppTheme.textSubtle),
                      SizedBox(height: 16),
                      Text('No projects yet', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchProjects(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatsSummary(),
                    const SizedBox(height: 16),
                    ...items.map((p) => _buildCard(p)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Row(
      children: [
        _statCard('Planning', _countByStatus('Planning'), const Color(0xFF3B82F6), Icons.work_outline),
        const SizedBox(width: 12),
        _statCard('In Progress', _countByStatus('In Progress'), const Color(0xFFF59E0B), Icons.trending_up),
        const SizedBox(width: 12),
        _statCard('Completed', _countByStatus('Completed'), const Color(0xFF10B981), Icons.check_circle_outline),
      ],
    );
  }

  Widget _statCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text('$count', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? AppTheme.primaryColor : AppTheme.borderColor),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'In Progress': return Colors.orange;
      case 'Planning': return Colors.blue;
      default: return AppTheme.textSubtle;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'Completed': return 'Completed \u2713';
      case 'In Progress': return 'In Progress \u25B6';
      default: return 'Planning \u25CB';
    }
  }

  String? _mainImageUrl(dynamic p) {
    final progressImages = (p['progressImages'] as List?) ?? [];
    final inProgress = progressImages.where((f) => f['status'] == 'In Progress' || f['status'] == null).toList();
    final completed = progressImages.where((f) => f['status'] == 'Completed').toList();
    if (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty) return p['imageUrl'];
    if (inProgress.isNotEmpty) return inProgress.last['url'];
    if (completed.isNotEmpty) return completed.last['url'];
    return null;
  }

  Widget _buildCard(dynamic p) {
    final status = (p['status'] ?? 'Planning').toString();
    final color = _statusColor(status);
    final progress = (p['progress'] ?? 0).toDouble();
    final progressImages = (p['progressImages'] as List?) ?? [];

    return GestureDetector(
      onTap: () => _openDetails(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image or placeholder
            ...() {
              final mainImg = _mainImageUrl(p);
              if (mainImg != null)
                return [
                  if (_isPdf(mainImg))
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red.shade300, size: 40),
                            const SizedBox(height: 4),
                            Text('PDF Document', style: TextStyle(color: Colors.red.shade400, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        '${ApiConstants.baseUrl}$mainImg',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          child: Center(child: Icon(Icons.work_outline, color: AppTheme.primaryColor.withValues(alpha: 0.3), size: 36)),
                        ),
                      ),
                    )
                ];
              return [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                      AppTheme.primaryColor.withValues(alpha: 0.05),
                    ]),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(child: Icon(Icons.work_outline, color: AppTheme.primaryColor.withValues(alpha: 0.3), size: 36)),
                ),
              ];
            }(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text(_statusLabel(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      if (_canCreate)
                        GestureDetector(
                          onTap: () => _confirmDelete(p['_id']),
                          child: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(p['title'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  if (p['description'] != null) ...[
                    const SizedBox(height: 6),
                    Text(p['description'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 12),
                  // Progress bar
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text('Progress', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${progress.toInt()}%', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: AppTheme.borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      minHeight: 6,
                    ),
                  ),
                  // Thumbnail previews
                  if (progressImages.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...() {
                      final inProgressImgs = progressImages.where((f) => f['status'] == 'In Progress').toList();
                      final completedImgs = progressImages.where((f) => f['status'] == 'Completed').toList();
                      final widgets = <Widget>[];
                      if (inProgressImgs.isNotEmpty) {
                        widgets.add(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text('Progress (${inProgressImgs.length})', style: TextStyle(color: Colors.orange.shade600, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 36,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: inProgressImgs.take(4).map((f) {
                                    final thumbUrl = '${ApiConstants.baseUrl}${f['url']}';
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(thumbUrl, width: 36, height: 36, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(width: 36, height: 36, color: Colors.orange.withValues(alpha: 0.1), child: Icon(Icons.image, size: 14, color: Colors.orange.shade300)),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (completedImgs.isNotEmpty) {
                        widgets.add(const SizedBox(height: 6));
                        widgets.add(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text('Completed (${completedImgs.length})', style: TextStyle(color: Colors.green.shade600, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 36,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: completedImgs.take(4).map((f) {
                                    final thumbUrl = '${ApiConstants.baseUrl}${f['url']}';
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(thumbUrl, width: 36, height: 36, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(width: 36, height: 36, color: Colors.green.withValues(alpha: 0.1), child: Icon(Icons.check_circle, size: 14, color: Colors.green.shade300)),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return widgets;
                    }(),
                  ],
                  const SizedBox(height: 12),
                  // Bottom info row
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.borderColor, width: 0.5))),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: AppTheme.primaryColor),
                        const SizedBox(width: 4),
                        Text(p['location'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        const Spacer(),
                        if (p['budget'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                            child: Text('\$${p['budget']}', style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPdf(String? url) {
    return url != null && url.toLowerCase().endsWith('.pdf');
  }

  void _confirmDelete(String id) {
    Get.defaultDialog(
      title: 'Delete Project',
      titleStyle: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
      backgroundColor: AppTheme.surfaceColor,
      middleText: 'Are you sure you want to delete this project?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await controller.deleteProject(id);
        Get.back();
        Get.snackbar('Deleted', 'Project deleted successfully');
      },
    );
  }

  void _openDetails(dynamic project) async {
    final details = await controller.fetchProjectDetails(project['_id']);
    if (details == null) return;
    if (!mounted) return;

    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailsSheet(
        project: details,
        canCreate: authController.user['role'] == 'admin' || authController.user['role'] == 'moderator',
        commentCtrl: commentCtrl,
        onAddComment: (text) async {
          final updated = await controller.addComment(details['_id'], text);
          if (updated != null && mounted) {
            Navigator.pop(context);
            _openDetails(updated);
          }
        },
        onUploadFile: (targetStatus) async => _uploadProgressFile(details, targetStatus),
      ),
    );
  }

  void _uploadProgressFile(dynamic project, String targetStatus) async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    Get.showSnackbar(GetSnackBar(
      message: 'Uploading ${file.name}...',
      duration: const Duration(seconds: 2),
    ));

    final url = await ApiService.uploadPlatformFile(file);
    if (url == null) return;

    final updated = await controller.addProgressFile(project['_id'], url, targetStatus);

    if (updated != null) {
      if (targetStatus == 'In Progress' && (project['status'] ?? '') == 'Planning') {
        await controller.updateProject(project['_id'], {'status': 'In Progress'});
      } else if (targetStatus == 'Completed') {
        await controller.updateProject(project['_id'], {'status': 'Completed', 'progress': 100});
      }
      await controller.fetchProjects();
      Get.snackbar('Success', 'File uploaded successfully');
    }
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String status = 'Planning';
    String? imageUrl;
    bool uploading = false;

    Get.defaultDialog(
      title: 'Register New Project',
      titleStyle: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
      backgroundColor: AppTheme.surfaceColor,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            width: Get.width * 0.85,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: _inputDecoration('Project Title')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: locationCtrl, decoration: _inputDecoration('District / Location'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: budgetCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('Budget (USD)'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(filled: true, fillColor: AppTheme.backgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: const [
                      DropdownMenuItem(value: 'Planning', child: Text('Planning')),
                      DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    ],
                    onChanged: (v) => setState(() => status = v ?? 'Planning'),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_graph, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          'Auto Progress: ${status == 'Completed' ? 100 : status == 'In Progress' ? 50 : 0}% (auto)',
                          style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.pickFiles();
                      if (result != null && result.files.isNotEmpty) {
                        setState(() => uploading = true);
                        final url = await ApiService.uploadPlatformFile(result.files.first);
                        setState(() {
                          imageUrl = url;
                          uploading = false;
                        });
                      }
                    },
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor, width: 1.5, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: uploading
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Center(child: Icon(Icons.description, color: AppTheme.primaryColor, size: 30)),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => setState(() => imageUrl = null),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload_file, color: AppTheme.textSubtle, size: 20),
                                    const SizedBox(height: 4),
                                    Text('Upload project file (optional)', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 3, decoration: _inputDecoration('Full Description')),
                ],
              ),
            ),
          );
        },
      ),
      textConfirm: 'Save Project',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        if (titleCtrl.text.isEmpty || locationCtrl.text.isEmpty) {
          Get.snackbar('Error', 'Title and Location are required');
          return;
        }
        final success = await controller.createProject({
          'title': titleCtrl.text.trim(),
          'description': descCtrl.text.trim(),
          'budget': budgetCtrl.text.isNotEmpty ? num.tryParse(budgetCtrl.text) : null,
          'location': locationCtrl.text.trim(),
          'status': status,
          if (imageUrl != null) 'imageUrl': imageUrl,
        });
        if (success) Get.back();
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSubtle),
      filled: true,
      fillColor: AppTheme.backgroundColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _DetailsSheet extends StatelessWidget {
  final dynamic project;
  final bool canCreate;
  final TextEditingController commentCtrl;
  final Function(String) onAddComment;
  final Function(String) onUploadFile;

  const _DetailsSheet({
    required this.project,
    required this.canCreate,
    required this.commentCtrl,
    required this.onAddComment,
    required this.onUploadFile,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (project['progress'] ?? 0).toDouble();
    final progressImages = (project['progressImages'] as List?) ?? [];
    final inProgressFiles = progressImages.where((f) => f['status'] == 'In Progress').toList();
    final completedFiles = progressImages.where((f) => f['status'] == 'Completed').toList();
    final comments = (project['comments'] as List?) ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.work_outline, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text('Project Details', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(project['title'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text(project['status'] ?? '', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 3),
                      Text(project['location'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      const SizedBox(width: 12),
                      if (project['budget'] != null) ...[
                        Icon(Icons.attach_money, size: 14, color: Colors.green.shade500),
                        Text('\$${project['budget']}', style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                  if (project['description'] != null) ...[
                    const SizedBox(height: 12),
                    Text(project['description'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5)),
                  ],
                  const SizedBox(height: 20),
                  // Progress
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppTheme.primaryColor.withOpacity(0.06),
                        AppTheme.primaryColor.withOpacity(0.03),
                      ]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 6),
                            Text('Project Progress', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text('${progress.toInt()}%', style: TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: AppTheme.borderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // In Progress Files
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('In Progress (${inProgressFiles.length})', style: TextStyle(color: Colors.orange.shade600, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (inProgressFiles.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: inProgressFiles.map((file) => _buildFileThumbnail(file, Colors.orange)).toList(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No progress files uploaded yet.', style: TextStyle(color: AppTheme.textSubtle, fontSize: 12, fontStyle: FontStyle.italic)),
                    ),

                  // Completed Files
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Completed (${completedFiles.length})', style: TextStyle(color: Colors.green.shade600, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (completedFiles.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: completedFiles.map((file) => _buildFileThumbnail(file, Colors.green)).toList(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No completed files uploaded yet.', style: TextStyle(color: AppTheme.textSubtle, fontSize: 12, fontStyle: FontStyle.italic)),
                    ),

                  // Upload buttons
                  if (canCreate) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if ((project['status'] ?? '').toLowerCase() != 'completed')
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onUploadFile('In Progress'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload_file, size: 16, color: Colors.orange.shade600),
                                    const SizedBox(width: 6),
                                    Text('Add Progress', style: TextStyle(color: Colors.orange.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if ((project['status'] ?? '').toLowerCase() != 'completed') const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onUploadFile('Completed'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file, size: 16, color: Colors.green.shade600),
                                  const SizedBox(width: 6),
                                  Text('Add Complete', style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Comments
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.comment_outlined, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Text('Comments (${comments.length})', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (comments.isNotEmpty)
                    ...comments.map((c) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c['authorName'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(
                                c['createdAt'] != null ? DateFormat('MMM d, yyyy HH:mm').format(DateTime.parse(c['createdAt'])) : '',
                                style: const TextStyle(color: AppTheme.textSubtle, fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(c['text'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4)),
                        ],
                      ),
                    ))
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('No comments yet.', style: TextStyle(color: AppTheme.textSubtle, fontSize: 12, fontStyle: FontStyle.italic)),
                    ),

                  // Add comment
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Add your feedback...',
                            hintStyle: const TextStyle(color: AppTheme.textSubtle),
                            filled: true,
                            fillColor: AppTheme.backgroundColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (commentCtrl.text.trim().isNotEmpty) {
                            onAddComment(commentCtrl.text.trim());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.send, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileThumbnail(dynamic file, Color color) {
    final url = '${ApiConstants.baseUrl}${file['url']}';
    final isPdf = (file['url'] as String?)?.toLowerCase().endsWith('.pdf') ?? false;

    return GestureDetector(
      onTap: () async {
        if (isPdf) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Show image in full screen
          showDialog(
            context: Get.context!,
            builder: (_) => Dialog(
              backgroundColor: Colors.black,
              insetPadding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Center(child: Image.network(url, fit: BoxFit.contain)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(Get.context!),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: isPdf
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, color: color, size: 28),
                  const SizedBox(height: 4),
                  Text('PDF', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image, color: color, size: 28),
                ),
              ),
      ),
    );
  }
}
