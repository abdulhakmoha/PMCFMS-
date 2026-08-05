import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/theme.dart';

class VirtualMeetingScreen extends StatefulWidget {
  final String? meetingId;
  final String? meetingTitle;
  const VirtualMeetingScreen({Key? key, this.meetingId, this.meetingTitle}) : super(key: key);

  @override
  State<VirtualMeetingScreen> createState() => _VirtualMeetingScreenState();
}

class _VirtualMeetingScreenState extends State<VirtualMeetingScreen> {
  final AuthController authCtrl = Get.find<AuthController>();
  late TextEditingController _roomCtrl;
  bool _audioEnabled = true;
  bool _videoEnabled = true;
  String _meetingType = 'public';

  @override
  void initState() {
    super.initState();
    _roomCtrl = TextEditingController(
      text: widget.meetingId != null ? 'PMCFMS-Meeting-${widget.meetingId}' : 'PMCFMS-Meeting-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  void dispose() {
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinMeeting() async {
    final room = _roomCtrl.text.trim();
    if (room.isEmpty) {
      Get.snackbar('Error', 'Room name is required');
      return;
    }

    final userName = authCtrl.user['name'] ?? 'User';
    final jitsiUrl = 'https://jitsi.belnet.be/$room#config.startWithAudioMuted=${!_audioEnabled}&config.startWithVideoMuted=${!_videoEnabled}&userInfo.displayName=$userName';

    Get.defaultDialog(
      title: 'Join Meeting',
      titleStyle: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
      backgroundColor: AppTheme.surfaceColor,
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam, size: 48, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            Text("Joining '$room' via Jitsi Meet.", style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Jitsi will open in your browser.', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11)),
          ],
        ),
      ),
      textConfirm: 'Open',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        final uri = Uri.parse(jitsiUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('Error', 'Could not open Jitsi Meet. Please install a browser.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Virtual Meeting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF10B981)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.videocam, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Video Conference', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Powered by Jitsi Meet', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        if (widget.meetingTitle != null) ...[
                          const SizedBox(height: 4),
                          Text(widget.meetingTitle!, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Room Name
            Text('Room Name', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _roomCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Barangay-Meeting-2026',
                hintStyle: const TextStyle(color: AppTheme.textSubtle),
                prefixIcon: const Icon(Icons.meeting_room_outlined, color: AppTheme.textSubtle, size: 20),
                filled: true, fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            // Meeting Type
            const Text('Meeting Type', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _typeChip('public', 'Public'),
                const SizedBox(width: 10),
                _typeChip('private', 'Private (Invite Only)'),
              ],
            ),
            const SizedBox(height: 24),
            // Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  _toggleRow('Enable Audio', Icons.mic_outlined, _audioEnabled, (v) => setState(() => _audioEnabled = v)),
                  const Divider(height: 20, color: AppTheme.borderColor),
                  _toggleRow('Enable Video', Icons.videocam_outlined, _videoEnabled, (v) => setState(() => _videoEnabled = v)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: _joinMeeting,
                icon: const Icon(Icons.videocam, color: Colors.white),
                label: Text('Join Meeting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Room ID: ${_roomCtrl.text.isNotEmpty ? _roomCtrl.text.substring(0, _roomCtrl.text.length > 20 ? 20 : _roomCtrl.text.length) : ''}...',
                  style: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label) {
    final active = _meetingType == value;
    return GestureDetector(
      onTap: () => setState(() => _meetingType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppTheme.primaryColor : AppTheme.borderColor),
        ),
        child: Text(label, style: TextStyle(color: active ? AppTheme.primaryColor : AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _toggleRow(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon, size: 20, color: value ? AppTheme.primaryColor : AppTheme.textSubtle),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
        Switch(
          value: value,
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
