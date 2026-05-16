import 'package:flutter/material.dart';
import '../theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _tab = 0;
  final _tabs = ['Feed', 'Outbreak map', 'Experts', 'Library'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Community',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 2),
                const Text('Farmers helping farmers',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ]),
            ),

            // Tab bar — sticky
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              decoration: BoxDecoration(
                color: AppColors.bg.withValues(alpha: 0.95),
                border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.4))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_tabs.length, (i) => Padding(
                    padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 6 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _tab == i ? AppColors.primary : AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_tabs[i], style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: _tab == i ? Colors.white : AppColors.textSecondary)),
                      ),
                    ),
                  )),
                ),
              ),
            ),

            // Tab content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_tab),
                  child: [
                    const _FeedTab(),
                    const _OutbreakTab(),
                    const _ExpertsTab(),
                    const _LibraryTab(),
                  ][_tab],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feed tab ──────────────────────────────────────────────────────────────────

class _FeedTab extends StatefulWidget {
  const _FeedTab();
  @override
  State<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<_FeedTab> {
  final _draftCtrl = TextEditingController();
  final List<_PostData> _posts = [
    _PostData('Pak Razak', 'Sekinchan, Selangor', '2h',
      'Caught early sheath blight in plot 3. Trichoderma spray + draining standing water did the trick. Anyone else seeing it after the rain?',
      24, 8),
    _PostData('Aishah', 'Kedah', '5h',
      'Bumper harvest from MR297 this season — 7.2 t/ha! Switched to organic neem oil rotation 3 months in.',
      67, 19),
    _PostData('Kumar', 'Perak', '1d',
      'Brown planthopper warning in Teluk Intan area. Check undersides of leaves daily this week.',
      41, 12),
  ];

  @override
  void dispose() { _draftCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Compose
        _card(child: Row(children: [
          Expanded(
            child: TextField(
              controller: _draftCtrl,
              decoration: InputDecoration(
                hintText: 'Share with your region…',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                filled: true,
                fillColor: AppColors.secondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_draftCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _posts.insert(0, _PostData('You', 'Selangor', 'now',
                    _draftCtrl.text.trim(), 0, 0));
                  _draftCtrl.clear();
                });
              }
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ])),
        const SizedBox(height: 14),
        ..._posts.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(p.name[0],
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                    color: AppColors.primary))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                  color: AppColors.textPrimary)),
                Text('${p.region} · ${p.time}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Paddy',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(p.content, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${p.likes}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${p.replies}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ])),
        )),
      ],
    );
  }
}

// ── Outbreak map tab ──────────────────────────────────────────────────────────

class _OutbreakTab extends StatelessWidget {
  const _OutbreakTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _card(child: Column(children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(painter: _MapPainter(), child: const SizedBox.expand()),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _legend(AppColors.accent, 'Low'),
            const SizedBox(width: 20),
            _legend(AppColors.amber, 'Medium'),
            const SizedBox(width: 20),
            _legend(AppColors.red, 'High'),
          ]),
        ])),
        const SizedBox(height: 12),
        _card(child: Column(children: [
          _riskRow(AppColors.red, 'Kedah', 'High risk'),
          const Divider(height: 1, color: AppColors.border),
          _riskRow(AppColors.amber, 'Selangor', 'Medium risk'),
          const Divider(height: 1, color: AppColors.border),
          _riskRow(AppColors.accent, 'Johor', 'Low risk'),
          const Divider(height: 1, color: AppColors.border),
          _riskRow(AppColors.amber, 'Pahang', 'Medium risk'),
        ])),
      ],
    );
  }

  Widget _legend(Color c, String l) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(l, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
  ]);

  Widget _riskRow(Color color, String region, String risk) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Expanded(child: Text(region, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
        color: AppColors.textPrimary))),
      Text(risk, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB7DEB8)..style = PaintingStyle.fill;
    final cx = size.width / 2, cy = size.height / 2;
    final path = Path()
      ..moveTo(cx - 60, cy - 70)
      ..cubicTo(cx - 20, cy - 100, cx + 60, cy - 80, cx + 80, cy - 20)
      ..cubicTo(cx + 90, cy + 30, cx + 40, cy + 80, cx, cy + 70)
      ..cubicTo(cx - 50, cy + 60, cx - 90, cy + 10, cx - 60, cy - 70)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 1.5);
    void dot(double x, double y, Color c) {
      canvas.drawCircle(Offset(x, y), 12, Paint()..color = c.withValues(alpha: 0.25));
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = c);
    }
    dot(cx - 30, cy - 30, AppColors.red);
    dot(cx + 10, cy + 10, AppColors.amber);
    dot(cx + 50, cy - 10, AppColors.amber);
    dot(cx - 10, cy + 40, AppColors.accent);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ── Experts tab ───────────────────────────────────────────────────────────────

class _ExpertsTab extends StatelessWidget {
  const _ExpertsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _card(child: Column(children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Dr. Lim Wei Han', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15,
                color: AppColors.textPrimary)),
              Text('MARDI · Plant Pathology · 18 yrs',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => _showBookingSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(child: Text('Book consultation',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
              ),
            ),
          ),
        ])),
        const SizedBox(height: 20),
        const Text('EXTENSION OFFICES',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        _card(child: Column(children: [
          _officeRow('DOA Selangor', '03-5510 1234'),
          const Divider(height: 1, color: AppColors.border),
          _officeRow('MARDI Serdang', '03-8943 7111'),
          const Divider(height: 1, color: AppColors.border),
          _officeRow('DOA Kedah', '04-733 1234'),
        ])),
        const SizedBox(height: 20),
        const Text('SUBSIDIES & GRANTS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _subsidyRow('Padi Subsidy Scheme (SSP)', 'RM 240/tonne for registered farmers.'),
          const SizedBox(height: 12),
          _subsidyRow('Fertilizer Subsidy (SBPN)', 'Free urea + NPK up to 2.4 ha.'),
          const SizedBox(height: 12),
          _subsidyRow('Crop Insurance (TPP)', 'Covers flood, pest, drought losses.'),
        ])),
      ],
    );
  }

  Widget _officeRow(String name, String phone) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.business_rounded, color: AppColors.info, size: 20),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
          color: AppColors.textPrimary)),
        Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    ]),
  );

  Widget _subsidyRow(String title, String desc) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
    const SizedBox(height: 2),
    Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
  ]);

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        final slots = ['Mon 10:00', 'Tue 14:00', 'Wed 09:00', 'Thu 11:00', 'Fri 15:00', 'Sat 10:00'];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 48, height: 4, decoration: BoxDecoration(
              color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Book a consultation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Choose a slot — confirmation by SMS.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true, crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
              childAspectRatio: 2.5,
              children: slots.map((s) => GestureDetector(
                onTap: () { Navigator.pop(context); },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(s, style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ]),
        );
      },
    );
  }
}

// ── Library tab ───────────────────────────────────────────────────────────────

class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  static const _videos = [
    (Icons.play_circle_outline_rounded, 'Identifying rice blast', '5 min'),
    (Icons.videocam_outlined, 'Organic pest control', '8 min'),
    (Icons.play_circle_outline_rounded, 'Water management', '6 min'),
    (Icons.videocam_outlined, 'Harvest timing', '4 min'),
  ];

  static const _calendar = [
    ('Mar–Apr', 'Land prep & nursery', AppColors.primary, AppColors.accentLight),
    ('May–Jun', 'Transplanting & vegetative', AppColors.info, AppColors.infoLight),
    ('Jul–Aug', 'Tillering & flowering', AppColors.accent, AppColors.accentLight),
    ('Sep–Oct', 'Ripening & harvest', AppColors.amber, AppColors.amberLight),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const Text('BEST PRACTICES LIBRARY',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.9,
          children: _videos.map((v) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primary.withValues(alpha: 0.05)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(child: Icon(v.$1, size: 40, color: AppColors.primary)),
                ),
              ),
              Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12,
                  color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(v.$3, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
            ]),
          )).toList(),
        ),
        const SizedBox(height: 20),
        const Text('SEASONAL CALENDAR',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        _card(child: Column(
          children: _calendar.asMap().entries.map((e) {
            final i = e.key;
            final c = e.value;
            return Padding(
              padding: EdgeInsets.only(bottom: i < _calendar.length - 1 ? 12 : 0),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: c.$4, borderRadius: BorderRadius.circular(20)),
                  child: Text(c.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.$3)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(c.$2, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
              ]),
            );
          }).toList(),
        )),
        const SizedBox(height: 20),
        const Text('SUCCESS STORIES',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.amber, size: 28),
          const SizedBox(height: 8),
          const Text('From 4 t/ha to 7 t/ha in two seasons',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Aishah from Kedah used VisionGRO\'s early detection alerts to cut losses by 60% and adopt cleaner spraying schedules.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ])),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _card({required Widget child}) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
    ],
  ),
  child: child,
);

class _PostData {
  final String name, region, time, content;
  final int likes, replies;
  _PostData(this.name, this.region, this.time, this.content, this.likes, this.replies);
}
