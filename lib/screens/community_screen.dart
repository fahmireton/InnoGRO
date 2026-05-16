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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Community', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 2),
                const Text('Farmers helping farmers', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_tabs.length, (i) => Padding(
                      padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: _tab == i ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: _tab == i ? AppColors.primary : AppColors.divider),
                          ),
                          child: Text(_tabs[i], style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: _tab == i ? Colors.white : AppColors.textSecondary)),
                        ),
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 4),
              ]),
            ),
            Expanded(
              child: IndexedStack(index: _tab, children: [
                _FeedTab(),
                _OutbreakTab(),
                _ExpertsTab(),
                _LibraryTab(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)]),
          child: Row(children: [
            const Expanded(child: TextField(
              decoration: InputDecoration(hintText: 'Share with your region...', border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            )),
            Container(width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18)),
          ]),
        ),
        const SizedBox(height: 14),
        _FeedPost(initial: 'P', name: 'Pak Razak', location: 'Sekinchan, Selangor', time: '2h',
          content: 'Caught early sheath blight in plot 3. Trichoderma spray + draining standing water did the trick. Anyone else seeing it after the rain?',
          likes: 24, replies: 8),
        const SizedBox(height: 12),
        _FeedPost(initial: 'A', name: 'Aishah', location: 'Kedah', time: '5h',
          content: 'Bumper harvest from MR297 this season — 7.2 t/ha! Switched to organic neem oil rotation 3 months in.',
          likes: 67, replies: 19),
        const SizedBox(height: 12),
        _FeedPost(initial: 'K', name: 'Kumar', location: 'Perak', time: '1d',
          content: 'Brown planthopper warning in Teluk Intan area. Check undersides of leaves daily this week.',
          likes: 41, replies: 12),
      ],
    );
  }
}

class _FeedPost extends StatelessWidget {
  final String initial, name, location, time, content;
  final int likes, replies;
  const _FeedPost({required this.initial, required this.name, required this.location, required this.time, required this.content, required this.likes, required this.replies});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
            child: Center(child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            Text('$location · $time', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(20)),
            child: const Text('Paddy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))),
        ]),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('$likes', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('$replies', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _OutbreakTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _sectionLabel('DISEASE OUTBREAK MAP'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2))]),
          child: Column(children: [
            Container(
              height: 220,
              decoration: BoxDecoration(color: const Color(0xFFE8F4FD), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
              child: CustomPaint(painter: _MapPainter(), child: const SizedBox.expand()),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _legend(const Color(0xFF4CAF50), 'Low'),
                const SizedBox(width: 20),
                _legend(AppColors.amber, 'Medium'),
                const SizedBox(width: 20),
                _legend(AppColors.red, 'High'),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
          child: Column(children: [
            _riskRow(AppColors.red, 'Kedah', 'High Risk', AppColors.red),
            _divider(),
            _riskRow(AppColors.amber, 'Selangor', 'Medium Risk', AppColors.amber),
            _divider(),
            _riskRow(const Color(0xFF4CAF50), 'Johor', 'Low Risk', const Color(0xFF4CAF50)),
            _divider(),
            _riskRow(AppColors.amber, 'Pahang', 'Medium Risk', AppColors.amber),
          ]),
        ),
      ],
    );
  }

  Widget _legend(Color c, String l) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(l, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
  ]);

  Widget _riskRow(Color dot, String region, String risk, Color riskColor) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Expanded(child: Text(region, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
      const SizedBox(width: 8),
      Text(risk, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: riskColor)),
    ]),
  );

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider);
  Widget _sectionLabel(String t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2));
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB7DEB8)
      ..style = PaintingStyle.fill;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    path.moveTo(cx - 60, cy - 70);
    path.cubicTo(cx - 20, cy - 100, cx + 60, cy - 80, cx + 80, cy - 20);
    path.cubicTo(cx + 90, cy + 30, cx + 40, cy + 80, cx, cy + 70);
    path.cubicTo(cx - 50, cy + 60, cx - 90, cy + 10, cx - 60, cy - 70);
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 2);
    void dot(double x, double y, Color c) {
      canvas.drawCircle(Offset(x, y), 14, Paint()..color = c.withValues(alpha: 0.3));
      canvas.drawCircle(Offset(x, y), 8, Paint()..color = c);
    }
    dot(cx - 30, cy - 30, Colors.red);
    dot(cx + 10, cy + 10, Colors.orange);
    dot(cx + 50, cy - 10, Colors.orange);
    dot(cx - 10, cy + 40, Colors.green);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _ExpertsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _sectionLabel('ASK AN EXPERT'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
          child: Column(children: [
            Row(children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 26)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Dr. Lim Wei Han', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
                const Text('MARDI · Plant Pathology · 18 yrs', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ]),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                child: const Text('Book consultation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              )),
          ]),
        ),
        const SizedBox(height: 24),
        _sectionLabel('EXTENSION OFFICES'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
          child: Column(children: [
            _officeRow('DOA Selangor', '03-5510 1234'),
            const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
            _officeRow('MARDI Serdang', '03-8943 7111'),
            const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
            _officeRow('DOA Kedah', '04-733 1234'),
          ]),
        ),
        const SizedBox(height: 24),
        _sectionLabel('SUBSIDIES & GRANTS'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
          child: Column(children: [
            _subsidyRow('Padi Subsidy Scheme (SSP)', 'RM 240/tonne for registered farmers.'),
            const SizedBox(height: 14),
            _subsidyRow('Fertilizer Subsidy (SBPN)', 'Free urea + NPK up to 2.4 ha.'),
            const SizedBox(height: 14),
            _subsidyRow('Crop Insurance (TPP)', 'Covers flood, pest, drought losses.'),
          ]),
        ),
      ],
    );
  }

  Widget _officeRow(String name, String phone) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.business_rounded, color: Color(0xFF1976D2), size: 20)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
        Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    ]),
  );

  Widget _subsidyRow(String title, String desc) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
    const SizedBox(height: 2),
    Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.amber)),
  ]);

  Widget _sectionLabel(String t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2));
}

class _LibraryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final videos = [
      (Icons.play_circle_outline_rounded, 'Identifying rice blast', '5 min'),
      (Icons.videocam_outlined, 'Organic pest control', '8 min'),
      (Icons.play_circle_outline_rounded, 'Water management', '6 min'),
      (Icons.videocam_outlined, 'Harvest timing', '4 min'),
    ];
    final calendar = [
      ('Mar-Apr', 'Land prep & nursery', const Color(0xFF4CAF50), const Color(0xFFE8F5E9)),
      ('May-Jun', 'Transplanting & vegetative', const Color(0xFF1976D2), const Color(0xFFE3F2FD)),
      ('Jul-Aug', 'Tillering & flowering', const Color(0xFF8BC34A), const Color(0xFFF1F8E9)),
      ('Sep-Oct', 'Ripening & harvest', const Color(0xFFFF9800), const Color(0xFFFFF3E0)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _sectionLabel('BEST PRACTICES LIBRARY'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 0.9,
          children: videos.map((v) => Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Container(
                decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                child: Center(child: Icon(v.$1, size: 40, color: AppColors.primary)),
              )),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(v.$3, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ),
            ]),
          )).toList(),
        ),
        const SizedBox(height: 24),
        _sectionLabel('SEASONAL CALENDAR'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
          child: Column(
            children: calendar.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: c.$4, borderRadius: BorderRadius.circular(20)),
                  child: Text(c.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.$3))),
                const SizedBox(width: 14),
                Text(c.$2, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              ]),
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),
        _sectionLabel('SUCCESS STORIES'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
          child: Row(children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.orange, size: 32),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('From 4 t/ha to 7 t/ha in two seasons', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              SizedBox(height: 4),
              Text('Ahmad from Kedah used early detection alerts to cut losses by 60% and optimise spray schedules.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
            ])),
          ]),
        ),
      ],
    );
  }

  Widget _sectionLabel(String t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2));
}
