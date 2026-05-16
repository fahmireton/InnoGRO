import 'package:flutter/material.dart';
import '../theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedTab = 0; // 0=Reminders, 1=Regional

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bg,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Alerts & Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _tabPill('Reminders', 0),
                    _tabPill('Regional', 1),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _selectedTab == 0 ? _buildRemindersTab() : _buildRegionalTab(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 12,
        ),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Reminder',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabPill(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRemindersTab() {
    return [
      // ── UPCOMING ──────────────────────────────────────────────
      _sectionLabel('UPCOMING'),
      _reminderCard(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.amber,
        iconBg: const Color(0xFFFFF3CD),
        title: 'Fertiliser Application Due',
        subtitle: '2nd split urea for Sawah Utara',
        timeLabel: 'Tomorrow',
        timeLabelColor: AppColors.amber,
      ),
      const SizedBox(height: 12),
      _reminderCard(
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.accent,
        iconBg: AppColors.accentLight,
        title: 'Field Inspection',
        subtitle: 'Monthly inspection for Sawah Selatan',
        timeLabel: 'In 3 days',
        timeLabelColor: AppColors.accent,
      ),
      const SizedBox(height: 12),
      _reminderCard(
        icon: Icons.info_rounded,
        iconColor: const Color(0xFF0369A1),
        iconBg: const Color(0xFFE0F2FE),
        title: 'Pesticide Window',
        subtitle: 'Optimal spray window based on weather forecast',
        timeLabel: 'In 5 days',
        timeLabelColor: const Color(0xFF0369A1),
      ),
      const SizedBox(height: 28),

      // ── COMPLETED ─────────────────────────────────────────────
      _sectionLabel('COMPLETED'),
      _completedCard(
        title: 'Irrigation Check',
        subtitle: 'Sawah Utara water level measured',
        completedDate: 'Completed 2 days ago',
      ),
      const SizedBox(height: 12),
      _completedCard(
        title: 'Fungicide Application',
        subtitle: 'Tricyclazole applied to Block A',
        completedDate: 'Completed 5 days ago',
      ),
    ];
  }

  List<Widget> _buildRegionalTab() {
    return [
      // ── DISEASE ALERTS ────────────────────────────────────────
      _sectionLabel('DISEASE ALERTS'),
      _diseaseAlertCard(
        severityEmoji: '🔴',
        severityLabel: 'HIGH',
        severityColor: AppColors.red,
        severityBg: const Color(0xFFFEE2E2),
        title: 'Rice Blast Outbreak in Kedah',
        description: '12 farms affected in Pendang district. Immediate preventive action recommended.',
        timeAgo: '2 days ago',
      ),
      const SizedBox(height: 12),
      _diseaseAlertCard(
        severityEmoji: '🟡',
        severityLabel: 'MEDIUM',
        severityColor: AppColors.amber,
        severityBg: const Color(0xFFFFF3CD),
        title: 'Brown Spot Pressure Rising in Selangor',
        description: 'Humid conditions favour pathogen spread. Monitor fields closely.',
        timeAgo: '4 days ago',
      ),
      const SizedBox(height: 12),
      _diseaseAlertCard(
        severityEmoji: '🟢',
        severityLabel: 'LOW',
        severityColor: AppColors.accent,
        severityBg: AppColors.accentLight,
        title: 'Bacterial Leaf Blight in Pahang',
        description: 'Isolated cases reported. Monitor closely, no widespread action required.',
        timeAgo: '1 week ago',
      ),
      const SizedBox(height: 28),

      // ── GOVERNMENT ADVISORIES ─────────────────────────────────
      _sectionLabel('GOVERNMENT ADVISORIES'),
      Container(
        decoration: _cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DOA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Department of Agriculture',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                const Text(
                  '3 days ago',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Apply preventive fungicide before booting stage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'DOA advises all paddy farmers to apply registered fungicides as a preventive measure before the crop reaches the booting stage to reduce blast incidence.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Container(
        decoration: _cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'MARDI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Research Institute',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                const Text(
                  '1 week ago',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'New Resistant Variety MR284 Available for Season 2',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'MARDI has released MR284, a blast-resistant variety with 15% higher yield potential. Seeds available at BERNAS distribution centres nationwide.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _reminderCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String timeLabel,
    required Color timeLabelColor,
  }) {
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: timeLabelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completedCard({
    required String title,
    required String subtitle,
    required String completedDate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.textSecondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completedDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _diseaseAlertCard({
    required String severityEmoji,
    required String severityLabel,
    required Color severityColor,
    required Color severityBg,
    required String title,
    required String description,
    required String timeAgo,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: severityColor, width: 4),
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(severityEmoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: severityBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  severityLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: severityColor,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text(
                timeAgo,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
