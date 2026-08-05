import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../../utils/theme.dart';
import '../polls/polls_screen.dart';
import '../documents/documents_screen.dart';
import '../projects/projects_screen.dart';
import '../issues/issues_screen.dart';
import '../settings/settings_screen.dart';
import '../meetings/virtual_meeting_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController controller = Get.put(DashboardController());
  final AuthController authCtrl = Get.find<AuthController>();
  final LanguageController langCtrl = Get.find<LanguageController>();

  bool get _isAdmin => authCtrl.user['role'] == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
                const SizedBox(height: 16),
                Text('Failed to load dashboard data', style: TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontBody)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => controller.fetchDashboardStats(), child: Text(langCtrl.t('retry'))),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchDashboardStats(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildChartsSection(),
              const SizedBox(height: 24),
              _buildBottomRow(),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text("Welcome back! Here's what's happening today.", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
        GestureDetector(
          onTap: () => _showReportModal(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Text('Generate Report', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _StatItem('Total Users', controller.totalUsers.toString(), Icons.people_alt_outlined, const Color(0xFF10B981), const Color(0xFF0D9488)),
      _StatItem('Active Meetings', controller.activeMeetings.toString(), Icons.event_note_outlined, const Color(0xFF6366F1), const Color(0xFF8B5CF6)),
      _StatItem('Open Forums', controller.openForums.toString(), Icons.forum_outlined, const Color(0xFFF59E0B), const Color(0xFFFBBF24)),
      _StatItem('Total Comments', controller.totalComments.toString(), Icons.trending_up, const Color(0xFF10B981), const Color(0xFF34D399)),
    ];

    final visibleStats = _isAdmin ? stats : stats.where((s) => s.label != 'Total Users').toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: visibleStats.map((s) => _buildStatCard(s)).toList(),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      width: (Get.width - 44) / (item.label == 'Total Users' && !_isAdmin ? 3 : 2),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [item.color1.withOpacity(0.08), item.color2.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color1.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [item.color1.withOpacity(0.15), item.color2.withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color1, size: 18),
          ),
          const SizedBox(height: 14),
          Text(item.value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1)),
          const SizedBox(height: 4),
          Text(item.label, style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        // Area Chart + Pie Chart row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildAreaChart()),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: _buildPieChart()),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAreaChart() {
    final data = controller.monthlyMeetings;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text('Meeting Growth', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('SCHEDULED PER MONTH', style: TextStyle(color: AppTheme.textSubtle, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: data.isEmpty
                ? Center(child: Text('No data', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1,
                        getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.primaryColor.withOpacity(0.08), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) =>
                          Text(v.toInt().toString(), style: TextStyle(color: AppTheme.textSubtle, fontSize: 9)))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < data.length) {
                            final label = data[idx]['_id']?.toString() ?? '';
                            return Padding(padding: const EdgeInsets.only(top: 6), child: Text(label.length > 3 ? label.substring(0, 3) : label, style: TextStyle(color: AppTheme.textSubtle, fontSize: 9)));
                          }
                          return const SizedBox();
                        })),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['count'] ?? 0).toDouble())).toList(),
                          isCurved: true,
                          color: AppTheme.primaryColor,
                          barWidth: 2.5,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.12)),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(getTooltipItems: (touched) =>
                          touched.map((t) => LineTooltipItem('${t.y.toInt()}', TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold))).toList()),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final data = controller.forumsByCategory;
    final colors = [AppTheme.primaryColor, const Color(0xFF6366F1), const Color(0xFFF59E0B), const Color(0xFFEF4444), const Color(0xFF8B5CF6)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text('Forums by Category', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: data.isEmpty
                ? Center(child: Text('No data', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 35,
                      sections: data.asMap().entries.map((e) {
                        final idx = e.key;
                        final item = e.value;
                        final count = (item['count'] ?? 0).toDouble();
                        return PieChartSectionData(
                          value: count,
                          color: colors[idx % colors.length],
                          radius: 40,
                          title: '${count.toInt()}',
                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          if (data.isNotEmpty)
            Column(
              children: data.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: colors[idx % colors.length], shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item['_id']?.toString() ?? '', style: TextStyle(color: AppTheme.textSubtle, fontSize: 8), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildBarChart()),
        const SizedBox(width: 12),
        Expanded(child: _buildRecentActivity()),
      ],
    );
  }

  Widget _buildBarChart() {
    final data = controller.usersByDistrict;
    final maxVal = data.isEmpty ? 1 : (data.map((d) => (d['count'] ?? 0) as num).reduce((a, b) => a > b ? a : b)).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text('Users by District', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: data.isEmpty
                ? Center(child: Text('No data', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)))
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxVal / 4,
                        getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.primaryColor.withOpacity(0.07), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) =>
                          Text(v.toInt().toString(), style: TextStyle(color: AppTheme.textSubtle, fontSize: 9)))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < data.length) {
                            final label = data[idx]['_id']?.toString() ?? '';
                            return Padding(padding: const EdgeInsets.only(top: 4), child: Text(label.length > 4 ? label.substring(0, 4) : label, style: TextStyle(color: AppTheme.textSubtle, fontSize: 8)));
                          }
                          return const SizedBox();
                        })),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      barGroups: data.asMap().entries.map((e) =>
                        BarChartGroupData(x: e.key, barRods: [
                          BarChartRodData(toY: (e.value['count'] ?? 0).toDouble(), color: AppTheme.primaryColor, width: 18, borderRadius: BorderRadius.circular(4)),
                        ])
                      ).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = controller.recentActivity;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: const Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Text('Recent Activity', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: activities.isEmpty
                ? Center(child: Text('No recent activity found.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)))
                : ListView.separated(
                    itemCount: activities.length.clamp(0, 5),
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.borderColor),
                    itemBuilder: (_, i) {
                      final act = activities[i];
                      final isMeeting = act['type'] == 'meeting';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: isMeeting ? AppTheme.primaryColor : const Color(0xFF8B5CF6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(act['action'] ?? '', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  if (act['details'] != null) ...[
                                    const SizedBox(height: 2),
                                    Text(act['details'], style: TextStyle(color: AppTheme.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                  if (act['time'] != null) ...[
                                    const SizedBox(height: 2),
                                    Text(act['time'], style: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(fontSize: AppTheme.fontCardTitle, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 14),
        _buildActionRow([
          _buildActionCard('Polls', Icons.how_to_vote_outlined, Colors.orange, () => Get.to(() => const PollsScreen())),
          _buildActionCard('Documents', Icons.description_outlined, Colors.teal, () => Get.to(() => const DocumentsScreen())),
          _buildActionCard('Projects', Icons.work_outline, Colors.indigo, () => Get.to(() => const ProjectsScreen())),
          _buildActionCard('Issues', Icons.report_problem_outlined, Colors.red, () => Get.to(() => const IssuesScreen())),
        ]),
        const SizedBox(height: 10),
        _buildActionRow([
          _buildActionCard('Virtual Mtg', Icons.videocam_outlined, Colors.teal, () => Get.to(() => const VirtualMeetingScreen())),
          _buildActionCard('Settings', Icons.settings_outlined, Colors.grey, () => Get.to(() => const SettingsScreen())),
        ]),
      ],
    );
  }

  Widget _buildActionRow(List<Widget> children) {
    return Row(
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c))).toList(),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontMeta, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showReportModal() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final monthlyData = controller.monthlyMeetings;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Report Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PMCFMS System Report', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text('Generated on $dateStr', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Summary Stats
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Summary Statistics', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (_isAdmin) ...[
                              Expanded(child: _reportStatCard('TOTAL USERS', controller.totalUsers.toString(), const Color(0xFF10B981))),
                              const SizedBox(width: 10),
                            ],
                            Expanded(child: _reportStatCard('ACTIVE MEETINGS', controller.activeMeetings.toString(), const Color(0xFF6366F1))),
                            const SizedBox(width: 10),
                            Expanded(child: _reportStatCard('OPEN FORUMS', controller.openForums.toString(), const Color(0xFFF59E0B))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _reportStatCard('TOTAL COMMENTS', controller.totalComments.toString(), const Color(0xFF10B981))),
                            if (!_isAdmin) ...[
                              const SizedBox(width: 10),
                              Expanded(child: SizedBox()),
                            ],
                          ],
                        ),
                        if (monthlyData.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Monthly Meeting Trend', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.borderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text('Month', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.bold))),
                                      Text('Meetings', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                ...monthlyData.map((m) => Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.borderColor))),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(m['_id']?.toString() ?? '', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12))),
                                      Text('${m['count'] ?? 0}', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                        if (controller.recentActivity.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Recent Activity', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...controller.recentActivity.take(5).map((a) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a['action'] ?? '', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                                      if (a['details'] != null)
                                        Text(a['details'], style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text(a['time'] ?? '', style: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                              ],
                            ),
                          )),
                        ],
                        const SizedBox(height: 20),
                        Divider(color: AppTheme.borderColor),
                        const SizedBox(height: 12),
                        Center(
                          child: Text('Public Meeting & Community Forum Management System (PMCFMS) — Confidential Report',
                              style: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
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

  Widget _reportStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color1;
  final Color color2;
  _StatItem(this.label, this.value, this.icon, this.color1, this.color2);
}
