import 'package:flutter/material.dart';
import '../theme.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  int _selectedCategory = 0;

  static const _categories = ['All', 'Disease', 'Pest', 'Nutrition'];

  static const _articles = [
    _Article(
      icon: Icons.blur_on_rounded,
      iconColor: Color(0xFFDC2626),
      iconBg: Color(0xFFFEE2E2),
      title: 'Identifying Brown Spot Early',
      excerpt: 'Brown spot appears as oval lesions with brown margins on leaf blades. Early detection prevents yield loss exceeding 45%.',
      readTime: '3 min read',
      category: 'Disease',
      categoryColor: Color(0xFFDC2626),
      categoryBg: Color(0xFFFEE2E2),
    ),
    _Article(
      icon: Icons.water_drop_rounded,
      iconColor: Color(0xFF0369A1),
      iconBg: Color(0xFFE0F2FE),
      title: 'Optimal Water Management',
      excerpt: 'Maintaining 2–5 cm water depth during the vegetative stage supports tillering and reduces weed pressure significantly.',
      readTime: '5 min read',
      category: 'Nutrition',
      categoryColor: Color(0xFF0369A1),
      categoryBg: Color(0xFFE0F2FE),
    ),
    _Article(
      icon: Icons.bug_report_rounded,
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFFF3CD),
      title: 'Integrated Pest Management',
      excerpt: 'IPM combines biological, cultural and chemical controls to manage pest populations below economic injury thresholds.',
      readTime: '4 min read',
      category: 'Pest',
      categoryColor: Color(0xFFF59E0B),
      categoryBg: Color(0xFFFFF3CD),
    ),
    _Article(
      icon: Icons.science_rounded,
      iconColor: Color(0xFF16A34A),
      iconBg: Color(0xFFDCFCE7),
      title: 'Understanding NPK for Paddy',
      excerpt: 'Nitrogen, phosphorus and potassium ratios affect grain filling, root development and overall crop resilience.',
      readTime: '6 min read',
      category: 'Nutrition',
      categoryColor: Color(0xFF0369A1),
      categoryBg: Color(0xFFE0F2FE),
    ),
    _Article(
      icon: Icons.shield_rounded,
      iconColor: Color(0xFF7C3AED),
      iconBg: Color(0xFFEDE9FE),
      title: 'Fungicide Resistance Prevention',
      excerpt: 'Rotating fungicide classes prevents resistance buildup and maintains chemical efficacy across multiple seasons.',
      readTime: '4 min read',
      category: 'Disease',
      categoryColor: Color(0xFFDC2626),
      categoryBg: Color(0xFFFEE2E2),
    ),
  ];

  static const _diseaseGuide = [
    _DiseaseEntry('Rice Blast', 'High', Color(0xFFDC2626), Color(0xFFFEE2E2), 'Diamond-shaped lesions on leaves'),
    _DiseaseEntry('Brown Spot', 'Medium', Color(0xFFF59E0B), Color(0xFFFFF3CD), 'Oval brown spots with yellow halo'),
    _DiseaseEntry('Sheath Blight', 'Medium', Color(0xFFF59E0B), Color(0xFFFFF3CD), 'Water-soaked lesions on sheath'),
  ];

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
              'Knowledge Hub',
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
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final selected = _selectedCategory == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          _categories[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── FEATURED ──────────────────────────────────────────
                _sectionLabel('FEATURED'),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A3D28), Color(0xFF2D5A3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Disease Management',
                          style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Rice Blast Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Learn how to identify, prevent and control rice blast — the most devastating fungal disease affecting paddy yields across Malaysia.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Read More',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time_rounded, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          const Text('8 min read', style: TextStyle(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── ARTICLES ──────────────────────────────────────────
                _sectionLabel('ARTICLES'),
                Column(
                  children: List.generate(_articles.length, (i) {
                    final a = _articles[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: i < _articles.length - 1 ? 12 : 0),
                      child: Container(
                        decoration: _cardDecoration,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: a.iconBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(a.icon, color: a.iconColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a.excerpt,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: a.categoryBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          a.category,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: a.categoryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.access_time_rounded,
                                          size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 3),
                                      Text(
                                        a.readTime,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textSecondary, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                // ── VIDEOS ────────────────────────────────────────────
                _sectionLabel('VIDEOS'),
                Row(
                  children: [
                    Expanded(child: _videoCard('Disease Scouting', '12:34')),
                    const SizedBox(width: 12),
                    Expanded(child: _videoCard('Spray Techniques', '08:55')),
                  ],
                ),
                const SizedBox(height: 28),

                // ── DISEASE GUIDE ─────────────────────────────────────
                _sectionLabel('DISEASE QUICK GUIDE'),
                Container(
                  decoration: _cardDecoration,
                  child: Column(
                    children: List.generate(_diseaseGuide.length, (i) {
                      final d = _diseaseGuide[i];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    d.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: d.badgeBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d.severity,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: d.badgeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    d.symptom,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < _diseaseGuide.length - 1)
                            const Divider(color: AppColors.divider, height: 1),
                        ],
                      );
                    }),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCard(String title, String duration) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1A3D28),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.play_circle_fill_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duration,
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Article {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String excerpt;
  final String readTime;
  final String category;
  final Color categoryColor;
  final Color categoryBg;

  const _Article({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.excerpt,
    required this.readTime,
    required this.category,
    required this.categoryColor,
    required this.categoryBg,
  });
}

class _DiseaseEntry {
  final String name;
  final String severity;
  final Color badgeColor;
  final Color badgeBg;
  final String symptom;

  const _DiseaseEntry(this.name, this.severity, this.badgeColor, this.badgeBg, this.symptom);
}
