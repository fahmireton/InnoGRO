import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              decoration: BoxDecoration(
                color: context.bg.withValues(alpha: 0.95),
                border: Border(
                    bottom: BorderSide(
                        color: context.border.withValues(alpha: 0.4))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                      _tabs.length,
                      (i) => Padding(
                            padding: EdgeInsets.only(
                                right: i < _tabs.length - 1 ? 6 : 0),
                            child: GestureDetector(
                              onTap: () => setState(() => _tab = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _tab == i
                                      ? AppColors.primary
                                      : context.secondary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_tabs[i],
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _tab == i
                                            ? Colors.white
                                            : context.textSecondary)),
                              ),
                            ),
                          )),
                ),
              ),
            ),
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

class _Post {
  final String authorName;
  final String region;
  final String content;
  int likes;
  final int replies;
  final String time;
  _Post({required this.authorName, required this.region, required this.content,
      required this.likes, required this.replies, required this.time});
}

class _FeedTab extends StatefulWidget {
  const _FeedTab();
  @override
  State<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<_FeedTab> {
  final _draftCtrl = TextEditingController();

  final List<_Post> _posts = [
    _Post(authorName: 'Ahmad Rizal', region: 'Kedah',
        content: 'Anyone else seeing brown leaf spot this season? Lost 20% of my yield last year to it.',
        likes: 12, replies: 4, time: '2h ago'),
    _Post(authorName: 'Siti Maimunah', region: 'Selangor',
        content: 'Tried the new MR297 variety this season. Very resistant to blast so far! Highly recommended.',
        likes: 34, replies: 8, time: '5h ago'),
    _Post(authorName: 'Rajan Kumar', region: 'Perak',
        content: 'Government fertilizer subsidy arrived late again. Anyone have contacts at DOA to follow up?',
        likes: 7, replies: 11, time: '1d ago'),
    _Post(authorName: 'Noraini Hamid', region: 'Johor',
        content: 'Just used VisionGRO to diagnose my field. Caught bacterial blight early — saved a lot of work!',
        likes: 21, replies: 3, time: '2d ago'),
    _Post(authorName: 'Hafiz Abdullah', region: 'Kedah',
        content: 'Flood hit 3 of my plots last week. Crop insurance (TPP) worth applying for? Anyone done it?',
        likes: 9, replies: 6, time: '3d ago'),
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
                  final text = _draftCtrl.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _posts.insert(0, _Post(
                        authorName: 'Farmer',
                        region: 'Malaysia',
                        content: text,
                        likes: 0,
                        replies: 0,
                        time: 'just now',
                      ));
                    });
                    _draftCtrl.clear();
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
        ..._posts.asMap().entries.map((entry) {
          final i = entry.key;
          final post = entry.value;
          return Padding(
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
                          child: Text(
                              post.authorName.isNotEmpty
                                  ? post.authorName[0].toUpperCase()
                                  : 'F',
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
                          Text(post.authorName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: context.textPrimary)),
                          Text('${post.region} · ${post.time}',
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
                  Text(post.content,
                      style: TextStyle(
                          fontSize: 13,
                          color: context.textPrimary,
                          height: 1.5)),
                  const SizedBox(height: 10),
                  Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => _posts[i].likes++),
                      child: Icon(Icons.favorite_border_rounded,
                          size: 16, color: context.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likes}',
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary)),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 16, color: context.textSecondary),
                    const SizedBox(width: 4),
                    Text('${post.replies}',
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
          );
        }),
      ],
    );
  }
}

// ── Outbreak map tab ──────────────────────────────────────────────────────────

class _OutbreakTab extends StatelessWidget {
  const _OutbreakTab();

  static const _outbreaks = [
    (state: 'Kedah', disease: 'Rice Blast', severity: 'High', lat: 6.1184, lng: 100.3685),
    (state: 'Selangor', disease: 'Brown Plant Hopper', severity: 'Medium', lat: 3.0738, lng: 101.5183),
    (state: 'Perak', disease: 'Sheath Blight', severity: 'Medium', lat: 4.5921, lng: 101.0901),
    (state: 'Johor', disease: 'Bacterial Blight', severity: 'Low', lat: 1.4854, lng: 103.7618),
    (state: 'Pahang', disease: 'Tungro Virus', severity: 'High', lat: 3.8126, lng: 103.3256),
    (state: 'Kelantan', disease: 'Rice Blast', severity: 'Medium', lat: 6.1254, lng: 102.2381),
    (state: 'Terengganu', disease: 'Leaf Folder', severity: 'Low', lat: 5.3117, lng: 103.1324),
    (state: 'Sabah', disease: 'Brown Plant Hopper', severity: 'Low', lat: 5.9788, lng: 116.0753),
    (state: 'Sarawak', disease: 'Sheath Rot', severity: 'Medium', lat: 1.5533, lng: 110.3592),
  ];

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.red;
      case 'medium':
        return AppColors.amber;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = _outbreaks.map((o) {
      final color = _severityColor(o.severity);
      return Marker(
        point: LatLng(o.lat, o.lng),
        width: 28,
        height: 28,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1),
            ],
          ),
        ),
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _card(context,
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(4.2105, 108.9758),
                      initialZoom: 6,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.innogro.app',
                      ),
                      MarkerLayer(markers: markers),
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
            child: Column(children: [
              ..._outbreaks.asMap().entries.map((entry) {
                final o = entry.value;
                final color = _severityColor(o.severity);
                final isLast = entry.key == _outbreaks.length - 1;
                return Column(children: [
                  _riskRow(context, color, o.state, o.disease, o.severity),
                  if (!isLast) Divider(height: 1, color: context.border),
                ]);
              }),
            ])),
      ],
    );
  }

  Widget _legend(Color c, String l, BuildContext context) =>
      Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(l,
            style: TextStyle(fontSize: 12, color: context.textSecondary)),
      ]);

  Widget _riskRow(BuildContext context, Color color, String region,
      String disease, String severity) =>
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text(region,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.textPrimary)),
            Text(disease,
                style:
                    TextStyle(fontSize: 11, color: context.textSecondary)),
          ])),
          Text('$severity risk',
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

  static const _experts = [
    (name: 'Dr. Lim Wei Han', institution: 'MARDI', specialization: 'Plant Pathology', experience: 15, available: true),
    (name: 'Prof. Siti Norzahra', institution: 'UPM', specialization: 'Rice Agronomy', experience: 20, available: false),
    (name: 'Dr. Rajendran Kumar', institution: 'DOA Kedah', specialization: 'Pest Management', experience: 12, available: true),
    (name: 'Dr. Amirul Hakim', institution: 'MARDI', specialization: 'Soil Science', experience: 10, available: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        ..._experts.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _card(context,
                  child: Column(children: [
                    Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(e.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: context.textPrimary)),
                            Text(
                                '${e.institution} · ${e.specialization} · ${e.experience} yrs',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: context.textSecondary)),
                          ])),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: e.available
                              ? AppColors.accentLight
                              : AppColors.redLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(e.available ? 'Available' : 'Busy',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: e.available
                                    ? AppColors.accent
                                    : AppColors.red)),
                      ),
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
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
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
                          onTap: e.available
                              ? () => _showBookingSheet(context, e.name)
                              : null,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: e.available
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.4),
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
            )),
        const SizedBox(height: 8),
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

  void _showBookingSheet(BuildContext context, String expertName) {
    String? selectedSlot;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        final slots = [
          'Mon 10:00', 'Tue 14:00', 'Wed 09:00',
          'Thu 11:00', 'Fri 15:00', 'Sat 10:00',
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
                            final messenger =
                                ScaffoldMessenger.of(context);
                            final nav = Navigator.of(sheetContext);
                            Future.delayed(
                                const Duration(milliseconds: 200), () {
                              nav.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Booking request sent for $s. Check your SMS for confirmation.'),
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
        Text('BEST PRACTICES LIBRARY',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.textSecondary,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.9,
          children: _videos
              .map((v) => GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening "${v.$2}"…'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: context.border.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary
                                          .withValues(alpha: 0.3),
                                      AppColors.primary
                                          .withValues(alpha: 0.05)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                child: Center(
                                    child: Icon(v.$1,
                                        size: 40,
                                        color: AppColors.primary)),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(v.$2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: context.textPrimary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  Text(v.$3,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: context.textSecondary)),
                                ])),
                          ]),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        Text('SEASONAL CALENDAR',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.textSecondary,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        _card(context,
            child: Column(
              children: _calendar.asMap().entries.map((e) {
                final i = e.key;
                final c = e.value;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i < _calendar.length - 1 ? 12 : 0),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: c.$4,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(c.$1,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: c.$3)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(c.$2,
                            style: TextStyle(
                                fontSize: 13,
                                color: context.textPrimary))),
                  ]),
                );
              }).toList(),
            )),
        const SizedBox(height: 20),
        Text('SUCCESS STORIES',
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
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.amber, size: 28),
              const SizedBox(height: 8),
              Text('From 4 t/ha to 7 t/ha in two seasons',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: context.textPrimary)),
              const SizedBox(height: 4),
              Text(
                  "Aishah from Kedah used VisionGRO's early detection alerts to cut losses by 60% and adopt cleaner spraying schedules.",
                  style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                      height: 1.5)),
            ])),
      ],
    );
  }
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
