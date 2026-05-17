import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _tab = 0;

  static const _tabs = [
    _TabItem('Feed', Icons.article_rounded),
    _TabItem('Outbreak map', Icons.map_rounded),
    _TabItem('Experts', Icons.people_rounded),
    _TabItem('Library', Icons.menu_book_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Community',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Text('Farmers helping farmers',
                    style: TextStyle(
                        fontSize: 14, color: context.textSecondary)),
              ]),
            ),

            // Tab bar — sticky, icon + text chips
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                color: context.bg.withValues(alpha: 0.97),
                border: Border(
                    bottom: BorderSide(
                        color: context.border.withValues(alpha: 0.4))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final active = _tab == i;
                    final tab = _tabs[i];
                    return Padding(
                      padding: EdgeInsets.only(
                          right: i < _tabs.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFF2E7D4F),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: active ? null : context.secondary,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: active
                                  ? Colors.transparent
                                  : context.border.withValues(alpha: 0.35),
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                              tab.icon,
                              size: 14,
                              color: active
                                  ? Colors.white
                                  : context.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? Colors.white
                                    : context.textSecondary,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Tab content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
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
  void dispose() {
    _draftCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Compose
        _card(context,
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _draftCtrl,
                  decoration: InputDecoration(
                    hintText: 'Share with your region…',
                    hintStyle: TextStyle(
                        color: context.textSecondary, fontSize: 13),
                    filled: true,
                    fillColor: context.secondary,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_draftCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _posts.insert(
                          0,
                          _PostData('You', 'Selangor', 'now',
                              _draftCtrl.text.trim(), 0, 0));
                      _draftCtrl.clear();
                    });
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ])),
        const SizedBox(height: 14),
        ..._posts.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _card(context,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: Text(p.name[0],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppColors.primary))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(p.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: context.textPrimary)),
                            Text('${p.region} · ${p.time}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: context.textSecondary)),
                          ])),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Paddy',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(p.content,
                        style: TextStyle(
                            fontSize: 13,
                            color: context.textPrimary,
                            height: 1.5)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Icon(Icons.favorite_border_rounded,
                          size: 16, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Text('${p.likes}',
                          style: TextStyle(
                              fontSize: 12, color: context.textSecondary)),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 16, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Text('${p.replies}',
                          style: TextStyle(
                              fontSize: 12, color: context.textSecondary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Feature coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Text('Reply',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ),
                    ]),
                  ])),
            )),
      ],
    );
  }
}

// ── Outbreak map tab ──────────────────────────────────────────────────────────

class _StateRisk {
  final String name, risk;
  final Color color;
  final double lat, lng;
  const _StateRisk(this.name, this.color, this.risk, this.lat, this.lng);
}

class _OutbreakTab extends StatelessWidget {
  const _OutbreakTab();

  static const _stateRisks = [
    _StateRisk('Kedah',        AppColors.red,   'High risk',   6.12,  100.37),
    _StateRisk('Perlis',       AppColors.amber, 'Medium risk', 6.44,  100.18),
    _StateRisk('Pulau Pinang', AppColors.amber, 'Medium risk', 5.42,  100.33),
    _StateRisk('Perak',        AppColors.accent,'Low risk',    4.60,  101.09),
    _StateRisk('Selangor',     AppColors.amber, 'Medium risk', 3.07,  101.52),
    _StateRisk('Johor',        AppColors.accent,'Low risk',    1.49,  103.76),
    _StateRisk('Pahang',       AppColors.amber, 'Medium risk', 3.81,  103.33),
    _StateRisk('Kelantan',     AppColors.red,   'High risk',   6.13,  102.24),
    _StateRisk('Terengganu',   AppColors.amber, 'Medium risk', 5.31,  103.14),
    _StateRisk('Sabah',        AppColors.accent,'Low risk',    5.98,  116.07),
    _StateRisk('Sarawak',      AppColors.accent,'Low risk',    1.55,  110.36),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _card(context,
            child: Column(children: [
              // ── Real flutter_map ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(4.5, 108.5),
                      initialZoom: 5.0,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.pinchZoom |
                            InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.innogro.app',
                      ),
                      MarkerLayer(
                        markers: _stateRisks.map((s) {
                          return Marker(
                            point: LatLng(s.lat, s.lng),
                            width: 80,
                            height: 48,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: s.color.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    s.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _legend(AppColors.accent, 'Low', context),
                const SizedBox(width: 20),
                _legend(AppColors.amber, 'Medium', context),
                const SizedBox(width: 20),
                _legend(AppColors.red, 'High', context),
              ]),
            ])),
        const SizedBox(height: 12),
        _card(context,
            child: Column(
                children: List.generate(_stateRisks.length, (i) {
              final s = _stateRisks[i];
              final isLast = i == _stateRisks.length - 1;
              return Column(children: [
                _riskRow(context, s.color, s.name, s.risk),
                if (!isLast) Divider(height: 1, color: context.border),
              ]);
            }))),
      ],
    );
  }

  Widget _legend(Color c, String l, BuildContext context) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(l,
            style: TextStyle(fontSize: 12, color: context.textSecondary)),
      ]);

  Widget _riskRow(
          BuildContext context, Color color, String region, String risk) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Icon(Icons.location_on_outlined,
              size: 14, color: context.textSecondary),
          const SizedBox(width: 4),
          Expanded(
              child: Text(region,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: context.textPrimary))),
          Text(risk,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ]),
      );
}

// ── Experts tab ───────────────────────────────────────────────────────────────

class _ExpertsTab extends StatelessWidget {
  const _ExpertsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _card(context,
            child: Column(children: [
              Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Dr. Lim Wei Han',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: context.textPrimary)),
                  Text('MARDI · Plant Pathology · 18 yrs',
                      style: TextStyle(
                          fontSize: 12, color: context.textSecondary)),
                ]),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Feature coming soon'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: context.secondary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                          child: Text('View profile',
                              style: TextStyle(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showBookingSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                          child: Text('Book consultation',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14))),
                    ),
                  ),
                ),
              ]),
            ])),
        const SizedBox(height: 20),
        Text('EXTENSION OFFICES',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.textSecondary,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        _card(context,
            child: Column(children: [
              _officeRow(context, 'DOA Selangor', '03-5510 1234'),
              Divider(height: 1, color: context.border),
              _officeRow(context, 'MARDI Serdang', '03-8943 7111'),
              Divider(height: 1, color: context.border),
              _officeRow(context, 'DOA Kedah', '04-733 1234'),
            ])),
        const SizedBox(height: 20),
        Text('SUBSIDIES & GRANTS',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.textSecondary,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        _card(context,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _subsidyRow(context, 'Padi Subsidy Scheme (SSP)',
                  'RM 240/tonne for registered farmers.'),
              const SizedBox(height: 12),
              _subsidyRow(context, 'Fertilizer Subsidy (SBPN)',
                  'Free urea + NPK up to 2.4 ha.'),
              const SizedBox(height: 12),
              _subsidyRow(context, 'Crop Insurance (TPP)',
                  'Covers flood, pest, drought losses.'),
            ])),
      ],
    );
  }

  Widget _officeRow(BuildContext context, String name, String phone) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.business_rounded,
                color: AppColors.info, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.textPrimary)),
            Text(phone,
                style: TextStyle(
                    fontSize: 12, color: context.textSecondary)),
          ]),
        ]),
      );

  Widget _subsidyRow(BuildContext context, String title, String desc) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: context.textPrimary)),
        const SizedBox(height: 2),
        Text(desc,
            style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
                height: 1.4)),
      ]);

  void _showBookingSheet(BuildContext context) {
    String? selectedSlot;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        final slots = [
          'Mon 10:00',
          'Tue 14:00',
          'Wed 09:00',
          'Thu 11:00',
          'Fri 15:00',
          'Sat 10:00'
        ];
        return StatefulBuilder(
          builder: (sheetContext, setS) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                      color: sheetContext.border,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Book a consultation',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: sheetContext.textPrimary)),
              const SizedBox(height: 4),
              Text('Choose a slot — confirmation by SMS.',
                  style: TextStyle(
                      fontSize: 13, color: sheetContext.textSecondary)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
                children: slots
                    .map((s) => GestureDetector(
                          onTap: () {
                            setS(() => selectedSlot = s);
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(sheetContext);
                            Future.delayed(
                                const Duration(milliseconds: 200), () {
                              nav.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Consultation booked for $s. Check your SMS for confirmation.'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              );
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: selectedSlot == s
                                  ? AppColors.primary
                                  : sheetContext.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                                child: Text(s,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selectedSlot == s
                                            ? Colors.white
                                            : sheetContext.textPrimary))),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        );
      },
    );
  }
}

// ── Library tab ───────────────────────────────────────────────────────────────

class _LibraryTab extends StatefulWidget {
  const _LibraryTab();
  @override
  State<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<_LibraryTab> {
  int? _playingIndex;

  static const _videos = [
    _VideoItem('Identifying Rice Blast', '5 min', 'assets/images/paddy_diseased2.png',
        'Learn to spot diamond-shaped lesions on leaves — the hallmark sign of blast infection.'),
    _VideoItem('Organic Pest Control', '8 min', 'assets/images/paddy_healthy.png',
        'Neem oil, Bacillus subtilis, and crop rotation methods that work without chemicals.'),
    _VideoItem('Water Management', '6 min', 'assets/images/paddyphase/Growing.png',
        'Alternate wetting and drying (AWD) to save up to 30% water while keeping yields high.'),
    _VideoItem('Harvest Timing', '4 min', 'assets/images/paddyphase/Harvest.png',
        'How to judge grain moisture and the right days-after-flowering to maximise grain weight.'),
  ];

  static const _calendar = [
    ('Mar–Apr', 'Land prep & nursery', AppColors.primary, AppColors.accentLight),
    ('May–Jun', 'Transplanting & vegetative', AppColors.info, AppColors.infoLight),
    ('Jul–Aug', 'Tillering & flowering', AppColors.accent, AppColors.accentLight),
    ('Sep–Oct', 'Ripening & harvest', AppColors.amber, AppColors.amberLight),
  ];

  static const _stories = [
    _Story('Aishah bt Yusof', 'Kedah', '4 t/ha → 7 t/ha',
        'Used AI early-detection alerts to cut blast losses by 60% and adopted neem oil rotation. Two seasons later, yield nearly doubled.',
        Icons.emoji_events_rounded, AppColors.amber),
    _Story('Pak Razak', 'Sekinchan, Selangor', 'Water savings 30%',
        'Switched to AWD irrigation after watching the water management tutorial. Saved RM 800/season on pumping costs with no yield drop.',
        Icons.water_drop_rounded, AppColors.info),
    _Story('Kumar Annamalai', 'Teluk Intan, Perak', '0 blast episodes',
        'Set up weekly AI scans on all 3 plots. Caught early BPH infestation twice before it spread — zero crop loss this season.',
        Icons.shield_rounded, AppColors.accent),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('BEST PRACTICES LIBRARY',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        ..._videos.asMap().entries.map((e) {
          final i = e.key;
          final v = e.value;
          final isPlaying = _playingIndex == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _playingIndex = isPlaying ? null : i),
              child: Container(
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.border.withValues(alpha: 0.4)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Thumbnail with play/pause overlay
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Stack(fit: StackFit.expand, children: [
                        Image.asset(v.thumbnail, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(gradient: LinearGradient(
                                colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.primary.withValues(alpha: 0.05)],
                              )),
                            )),
                        // Dark overlay
                        DecoratedBox(decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.5)],
                          ),
                        )),
                        // Play/Pause button
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: isPlaying ? AppColors.red : Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12)],
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: isPlaying ? Colors.white : AppColors.primary,
                              size: 30,
                            ),
                          ),
                        ),
                        // Duration badge
                        Positioned(bottom: 8, right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6)),
                            child: Text(v.duration, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          )),
                      ]),
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(v.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.textPrimary)),
                      if (isPlaying) ...[
                        const SizedBox(height: 6),
                        Text(v.description, style: TextStyle(fontSize: 12, color: context.textSecondary, height: 1.4)),
                        const SizedBox(height: 10),
                        // Simulated progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(value: 0.38, minHeight: 4,
                            backgroundColor: context.secondary,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
                        ),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('1:55', style: TextStyle(fontSize: 10, color: context.textSecondary)),
                          Text(v.duration, style: TextStyle(fontSize: 10, color: context.textSecondary)),
                        ]),
                      ] else
                        Text(v.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: context.textSecondary)),
                    ]),
                  ),
                ]),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        Text('SEASONAL CALENDAR',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        _card(context,
            child: Column(
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
                    Expanded(child: Text(c.$2, style: TextStyle(fontSize: 13, color: context.textPrimary))),
                  ]),
                );
              }).toList(),
            )),

        const SizedBox(height: 20),
        Text('SUCCESS STORIES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        ..._stories.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _card(context, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: s.iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(s.icon, color: s.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.textPrimary)),
                Text(s.location, style: TextStyle(fontSize: 11, color: context.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: s.iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(s.result, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: s.iconColor)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(s.story, style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.5)),
          ])),
        )),
      ],
    );
  }
}

class _VideoItem {
  final String title, duration, thumbnail, description;
  const _VideoItem(this.title, this.duration, this.thumbnail, this.description);
}

class _Story {
  final String name, location, result, story;
  final IconData icon;
  final Color iconColor;
  const _Story(this.name, this.location, this.result, this.story, this.icon, this.iconColor);
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _card(BuildContext context, {required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );

class _PostData {
  final String name, region, time, content;
  final int likes, replies;
  _PostData(this.name, this.region, this.time, this.content, this.likes,
      this.replies);
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem(this.label, this.icon);
}
