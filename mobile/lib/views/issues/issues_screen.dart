import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/issue_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/api_constants.dart';
import '../../utils/theme.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({Key? key}) : super(key: key);

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final IssueController controller = Get.put(IssueController());
  final AuthController authController = Get.find<AuthController>();
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    controller.fetchIssues();
  }

  bool get _isAdmin => authController.user['role'] == 'admin' || authController.user['role'] == 'moderator';

  List<dynamic> get _filtered {
    if (_filter == 'all') return controller.issues;
    return controller.issues.where((i) => (i['status'] ?? '').toString().toLowerCase() == _filter.toLowerCase()).toList();
  }

  int _countByStatus(String status) {
    return controller.issues.where((i) => (i['status'] ?? '').toString().toLowerCase() == status.toLowerCase()).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Issues & Concerns')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showCreateDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip('all', 'All'),
                const SizedBox(width: 8),
                _filterChip('pending', 'Pending'),
                const SizedBox(width: 8),
                _filterChip('under review', 'Review'),
                const SizedBox(width: 8),
                _filterChip('resolved', 'Resolved'),
                const SizedBox(width: 8),
                _filterChip('rejected', 'Rejected'),
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
                      Icon(Icons.check_circle_outline, size: 64, color: AppTheme.textSubtle),
                      SizedBox(height: 16),
                      Text('No issues reported', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchIssues(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatsSummary(),
                    const SizedBox(height: 16),
                    ...items.map((issue) => _buildCard(issue)),
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
        _statCard('Pending', _countByStatus('pending'), const Color(0xFFF59E0B), Icons.pending_outlined),
        const SizedBox(width: 8),
        _statCard('Review', _countByStatus('under review'), const Color(0xFF3B82F6), Icons.search),
        const SizedBox(width: 8),
        _statCard('Resolved', _countByStatus('resolved'), const Color(0xFF10B981), Icons.check_circle_outline),
        const SizedBox(width: 8),
        _statCard('Rejected', _countByStatus('rejected'), const Color(0xFFF43F5E), Icons.cancel_outlined),
      ],
    );
  }

  Widget _statCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text('$count', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? AppTheme.primaryColor : AppTheme.borderColor),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Color _statusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'under review': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.blue;
      default: return AppTheme.textSubtle;
    }
  }

  Color _statusBarColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'under review': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.blue;
      default: return AppTheme.textSubtle;
    }
  }

  Widget _buildCard(dynamic issue) {
    final status = (issue['status'] ?? 'pending').toString();
    final color = _statusColor(status);
    final barColor = _statusBarColor(status);
    final comments = (issue['comments'] as List?) ?? [];

    return GestureDetector(
      onTap: () => _openDetails(issue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left status bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                            child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          if (_isAdmin && status != 'Resolved' && status != 'Rejected')
                            GestureDetector(
                              onTap: () => _showAdminUpdate(issue),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF06B6D4)]),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Manage', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          if (_isAdmin)
                            Padding(
                              padding: EdgeInsets.only(left: _isAdmin && status != 'Resolved' && status != 'Rejected' ? 0 : 0),
                              child: GestureDetector(
                                onTap: () => _confirmDelete(issue['_id']),
                                child: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 16),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(issue['title'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                      if (issue['description'] != null) ...[
                        const SizedBox(height: 6),
                        Text(issue['description'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      if (issue['adminNotes'] != null && (issue['adminNotes'] as String).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 12, color: Colors.green.shade500),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Admin: ${issue['adminNotes']}',
                                  style: TextStyle(color: Colors.green.shade600, fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.borderColor, width: 0.5))),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: AppTheme.primaryColor),
                            const SizedBox(width: 3),
                            Text(issue['district'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                            const Spacer(),
                            Icon(Icons.access_time, size: 11, color: AppTheme.textSubtle),
                            const SizedBox(width: 3),
                            Text(
                              issue['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(issue['createdAt'])) : '',
                              style: const TextStyle(color: AppTheme.textSubtle, fontSize: 10),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.comment_outlined, size: 11, color: AppTheme.textSubtle),
                            const SizedBox(width: 3),
                            Text('${comments.length}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                            if (issue['citizen'] != null) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.person_outline, size: 11, color: AppTheme.textSubtle),
                              const SizedBox(width: 3),
                              Text(issue['citizen']['name'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    Get.defaultDialog(
      title: 'Delete Issue',
      titleStyle: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
      backgroundColor: AppTheme.surfaceColor,
      middleText: 'Are you sure you want to delete this issue?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await controller.deleteIssue(id);
        Get.back();
        Get.snackbar('Deleted', 'Issue deleted successfully');
      },
    );
  }

  void _openDetails(dynamic issue) {
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IssueDetailsSheet(
        issue: issue,
        isAdmin: _isAdmin,
        commentCtrl: commentCtrl,
        onAddComment: (text) async {
          final updated = await controller.addComment(issue['_id'], text);
          if (updated != null && mounted) {
            Navigator.pop(context);
            _openDetails(updated);
          }
        },
        onManage: () {
          Navigator.pop(context);
          _showAdminUpdate(issue);
        },
      ),
    );
  }

  void _showAdminUpdate(dynamic issue) {
    String status = issue['status'] ?? 'Pending';
    final notesCtrl = TextEditingController(text: issue['adminNotes'] ?? '');

    Get.defaultDialog(
      title: 'Issue Management',
      titleStyle: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
      backgroundColor: AppTheme.surfaceColor,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            width: Get.width * 0.85,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Managing:', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11)),
                      const SizedBox(height: 3),
                      Text(issue['title'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'New Status',
                    labelStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Under Review', child: Text('Under Review')),
                    DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
                    DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                  ],
                  onChanged: (v) => setState(() => status = v ?? 'Pending'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Admin Response',
                    labelStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 12),
                    hintText: 'Write a response about this issue...',
                    hintStyle: const TextStyle(color: AppTheme.textSubtle),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final success = await controller.updateIssueStatus(
                            issue['_id'],
                            status,
                            adminNotes: notesCtrl.text.trim(),
                          );
                          if (success) {
                            Get.back();
                            Get.snackbar('Updated', 'Issue status updated');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF0D9488)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('Save Response', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final success = await controller.updateIssueStatus(
                          issue['_id'],
                          'Rejected',
                          adminNotes: 'This issue was rejected by the moderation team.',
                        );
                        if (success) {
                          Get.back();
                          Get.snackbar('Rejected', 'Issue has been rejected');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      textConfirm: '',
      textCancel: '',
    );
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final districtCtrl = TextEditingController(text: 'Banadir');
    String priority = 'low';
    String? imageUrl;
    bool uploading = false;

    Get.defaultDialog(
      title: 'Submit Issue',
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
                  TextField(controller: titleCtrl, decoration: _inputDecoration('Issue Title')),
                  const SizedBox(height: 12),
                  TextField(controller: districtCtrl, decoration: _inputDecoration('District / Neighborhood')),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 4, decoration: _inputDecoration('Describe the issue...')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: InputDecoration(filled: true, fillColor: AppTheme.backgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                      DropdownMenuItem(value: 'high', child: Text('High Priority')),
                    ],
                    onChanged: (v) => setState(() => priority = v ?? 'low'),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.pickFiles(type: FileType.image);
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
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: uploading
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : imageUrl != null
                              ? Stack(
                                  children: [
                                    Center(child: Icon(Icons.check_circle, color: Colors.green, size: 24)),
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
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, color: AppTheme.textSubtle, size: 20),
                                    const SizedBox(height: 4),
                                    Text('Attach photo (optional)', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11)),
                                  ],
                                ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      textConfirm: 'Submit Issue',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
          Get.snackbar('Error', 'Title and description are required');
          return;
        }
        final success = await controller.createIssue({
          'title': titleCtrl.text.trim(),
          'description': descCtrl.text.trim(),
          'district': districtCtrl.text.trim(),
          'priority': priority,
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

class _IssueDetailsSheet extends StatelessWidget {
  final dynamic issue;
  final bool isAdmin;
  final TextEditingController commentCtrl;
  final Function(String) onAddComment;
  final VoidCallback onManage;

  const _IssueDetailsSheet({
    required this.issue,
    required this.isAdmin,
    required this.commentCtrl,
    required this.onAddComment,
    required this.onManage,
  });

  Color _statusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'under review': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.blue;
      default: return AppTheme.textSubtle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = (issue['comments'] as List?) ?? [];
    final status = issue['status'] ?? 'Pending';
    final color = _statusColor(status);
    final isUnderReview = status == 'Under Review';
    final isRejected = status == 'Rejected';

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
                  Icon(Icons.report_outlined, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text('Issue Details', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (isAdmin)
                    GestureDetector(
                      onTap: onManage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF06B6D4)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Manage', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(width: 8),
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
                  Text(issue['title'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 3),
                      Text(issue['district'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 12, color: AppTheme.textSubtle),
                      const SizedBox(width: 3),
                      Text(
                        issue['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(issue['createdAt'])) : '',
                        style: const TextStyle(color: AppTheme.textSubtle, fontSize: 11),
                      ),
                    ],
                  ),
                  if (issue['description'] != null) ...[
                    const SizedBox(height: 14),
                    Text(issue['description'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5)),
                  ],
                  // Image
                  if (issue['imageUrl'] != null && (issue['imageUrl'] as String).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final url = '${ApiConstants.baseUrl}${issue['imageUrl']}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          '${ApiConstants.baseUrl}${issue['imageUrl']}',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(child: Icon(Icons.broken_image, color: AppTheme.textSubtle, size: 30)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Center(
                        child: Text('Tap to view full image', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10)),
                      ),
                    ),
                  ],
                  // Admin notes
                  if (issue['adminNotes'] != null && (issue['adminNotes'] as String).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 14, color: Colors.green.shade500),
                              const SizedBox(width: 5),
                              Text('Official Response', style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(issue['adminNotes'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4)),
                        ],
                      ),
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
                      Text('Discussion (${comments.length})', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
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
                                c['createdAt'] != null ? DateFormat('MMM d, HH:mm').format(DateTime.parse(c['createdAt'])) : '',
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
                  if (isUnderReview)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 14, color: Colors.orange.shade500),
                          const SizedBox(width: 6),
                          Text('Comments locked while Under Review', style: TextStyle(color: Colors.orange.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  else if (isRejected)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('Comments disabled for rejected issues', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11, fontStyle: FontStyle.italic)),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentCtrl,
                            decoration: InputDecoration(
                              hintText: 'Share a detail or update...',
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
}
