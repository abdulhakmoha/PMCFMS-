import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/announcement_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/theme.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final AnnouncementController controller = Get.put(AnnouncementController());
  final AuthController authController = Get.find<AuthController>();
  String _category = 'all';

  @override
  void initState() {
    super.initState();
    controller.fetchAnnouncements();
  }

  bool get _canManage => authController.user['role'] == 'admin' || authController.user['role'] == 'moderator';

  List<dynamic> get _filtered {
    if (_category == 'all') return controller.announcements;
    return controller.announcements.where((a) => (a['category'] ?? '').toString().toLowerCase() == _category.toLowerCase()).toList();
  }

  Color _catColor(String? cat) {
    switch (cat) {
      case 'Urgent': return Colors.red;
      case 'Meeting': return const Color(0xFF10B981);
      default: return const Color(0xFF14B8A6);
    }
  }

  Color? _catBg(String? cat) {
    switch (cat) {
      case 'Urgent': return Colors.red.withValues(alpha: 0.12);
      case 'Meeting': return const Color(0xFF10B981).withValues(alpha: 0.12);
      default: return const Color(0xFF14B8A6).withValues(alpha: 0.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Community Announcements'),
        actions: [
          if (_canManage)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              onPressed: () => _showCreateSheet(),
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
                _catChip('general', 'General'),
                const SizedBox(width: 8),
                _catChip('meeting', 'Meeting'),
                const SizedBox(width: 8),
                _catChip('urgent', 'Urgent'),
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
                        child: const Icon(Icons.campaign_outlined, size: 36, color: AppTheme.textSubtle),
                      ),
                      const SizedBox(height: 16),
                      const Text('No announcements yet', style: TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontCardTitle)),
                      const SizedBox(height: 4),
                      const Text('New announcements will appear here when posted.', style: TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchAnnouncements(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildCard(items[index], index),
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

  Widget _buildCard(dynamic a, int index) {
    final cat = a['category'] ?? 'General';
    final color = _catColor(cat);
    return Container(
          margin: const EdgeInsets.only(bottom: 14),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _catBg(cat), borderRadius: BorderRadius.circular(8)),
                          child: Text(cat, style: TextStyle(color: color, fontSize: AppTheme.fontSmall, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        if (a['createdAt'] != null || a['date'] != null)
                          Text(
                            DateFormat('MMM d, yyyy').format(DateTime.parse(a['date'] ?? a['createdAt'])),
                            style: const TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall),
                          ),
                        const Spacer(),
                        if (_canManage)
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: AppTheme.textSubtle, size: 18),
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
                              if (v == 'delete') await controller.deleteAnnouncement(a['_id']);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(a['title'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontCardTitle, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(a['content'] ?? a['body'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontBody, height: 1.5)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.borderColor, width: 0.5))),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 12, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text('Posted by: ', style: TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall)),
                          Text(
                            a['creator']?['name'] ?? 'Unknown',
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontSmall, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              (a['creator']?['role'] ?? '').toString().capitalizeFirst!,
                              style: TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall - 1, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    ),
  );
  }

  void _showCreateSheet() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String category = 'General';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
            Container(height: 4, width: double.infinity, color: AppTheme.primaryColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.campaign_outlined, size: 20, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('New Announcement', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter announcement title...',
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
                      DropdownMenuItem(value: 'General', child: Text('General')),
                      DropdownMenuItem(value: 'Meeting', child: Text('Meeting')),
                      DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
                    ],
                    onChanged: (v) => setState(() => category = v ?? 'General'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      hintText: 'Write the full announcement content...',
                      filled: true, fillColor: AppTheme.backgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) {
                          Get.snackbar('Error', 'Title and content are required');
                          return;
                        }
                        final success = await controller.createAnnouncement({
                          'title': titleCtrl.text.trim(),
                          'content': contentCtrl.text.trim(),
                          'category': category,
                        });
                        if (success) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Publish Announcement', style: TextStyle(fontSize: AppTheme.fontBody, fontWeight: FontWeight.bold)),
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
}
