import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/forum_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/theme.dart';

class ForumDetailsScreen extends StatefulWidget {
  final String forumId;

  const ForumDetailsScreen({Key? key, required this.forumId}) : super(key: key);

  @override
  State<ForumDetailsScreen> createState() => _ForumDetailsScreenState();
}

class _ForumDetailsScreenState extends State<ForumDetailsScreen> {
  final ForumController controller = Get.put(ForumController());
  final AuthController authController = Get.find<AuthController>();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchForumDetails(widget.forumId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Discussion'),
        actions: [
          Obx(() {
            final forum = controller.currentForum;
            final score = ((forum['upvotes'] as List?)?.length ?? 0) - ((forum['downvotes'] as List?)?.length ?? 0);
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await controller.voteForum(widget.forumId, 'upvote');
                        controller.fetchForumDetails(widget.forumId);
                      },
                      icon: Icon(Icons.arrow_upward, color: AppTheme.primaryColor, size: 22),
                    ),
                    Text('$score', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: AppTheme.fontSectionTitle)),
                    IconButton(
                      onPressed: () async {
                        await controller.voteForum(widget.forumId, 'downvote');
                        controller.fetchForumDetails(widget.forumId);
                      },
                      icon: Icon(Icons.arrow_downward, color: AppTheme.errorColor, size: 22),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }

        final forum = controller.currentForum;
        if (forum.isEmpty) {
          return const Center(child: Text('Forum not found', style: TextStyle(color: AppTheme.textPrimary)));
        }

        final isApproved = forum['isApproved'] ?? false;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildForumHeader(forum, isApproved),
                    const SizedBox(height: 24),
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
            if (isApproved) _buildCommentInput(),
          ],
        );
      }),
    );
  }

  Widget _buildForumHeader(Map forum, bool isApproved) {
    final author = forum['author'] ?? {};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(forum['category'] ?? 'General',
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: AppTheme.fontMeta, fontWeight: FontWeight.bold)),
              ),
              if (!isApproved) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Pending Approval',
                      style: TextStyle(color: Colors.amber, fontSize: AppTheme.fontMeta, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(forum['title'] ?? '',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontSectionTitle, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: Text(
                  (author['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: AppTheme.fontMeta),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author['name'] ?? 'Unknown', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: AppTheme.fontBody)),
                  Text(
                    '${author['role'] ?? 'Citizen'} · ${forum['createdAt'] != null ? _formatDate(forum['createdAt']) : ''}',
                    style: const TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontMeta),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(forum['description'] ?? '',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontCardTitle, height: 1.6)),
          // Image Gallery
          if (forum['images'] != null && (forum['images'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: (forum['images'] as List).length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final imgUrl = (forum['images'] as List)[i];
                  final fullUrl = imgUrl.toString().startsWith('http') ? imgUrl.toString() : 'http://10.0.2.2:5001$imgUrl';
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector(
                      onTap: () => Get.dialog(
                        Dialog(
                          backgroundColor: Colors.transparent,
                          child: InteractiveViewer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(fullUrl, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                      child: Image.network(fullUrl, width: 100, height: 100, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.broken_image, color: AppTheme.textSubtle),
                          )),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Obx(() {
      final comments = controller.forumComments;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Responses (${comments.length})',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontSectionTitle, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Text('No responses yet. Be the first to share your thoughts!',
                  textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSubtle)),
            )
          else
            ...comments.map((comment) {
              final author = comment['author'] ?? {};
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: Text(
                        (author['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: AppTheme.fontMeta),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(author['name'] ?? 'Unknown',
                                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: AppTheme.fontBody)),
                              Text(
                                comment['createdAt'] != null ? _formatDate(comment['createdAt']) : '',
                                style: const TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontSmall),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(comment['text'] ?? '',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontBody, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      );
    });
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Write your response...',
                  hintStyle: const TextStyle(color: AppTheme.textSubtle),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(() => IconButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () async {
                      if (_commentController.text.trim().isEmpty) return;
                      final success = await controller.postComment(widget.forumId, _commentController.text.trim());
                      if (success) _commentController.clear();
                    },
              icon: controller.isSubmitting.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                  : const Icon(Icons.send, color: AppTheme.primaryColor),
            )),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
