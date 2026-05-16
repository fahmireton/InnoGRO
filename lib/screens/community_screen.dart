import 'package:flutter/material.dart';
import '../theme.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Community')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PostCard(
            avatar: '👨‍🌾',
            name: 'Ahmad Razif',
            location: 'Kedah',
            time: '2h ago',
            title: 'Brown Spot outbreak in Merbok area',
            body: 'Seeing a lot of brown spot this season. Anyone else affected? I used Mancozeb 80WP and it helped within a week.',
            likes: 24,
            replies: 8,
            tag: 'Disease Alert',
            tagColor: AppColors.red,
            tagBg: AppColors.redLight,
          ),
          const SizedBox(height: 14),
          _PostCard(
            avatar: '👩‍🌾',
            name: 'Siti Hajar',
            location: 'Perlis',
            time: '5h ago',
            title: 'MR263 variety performing well this season',
            body: 'Just harvested 6.2 MT/ha with MR263. The blast resistance is excellent. Highly recommend for Perlis farmers.',
            likes: 41,
            replies: 15,
            tag: 'Success Story',
            tagColor: AppColors.accent,
            tagBg: AppColors.accentLight,
          ),
          const SizedBox(height: 14),
          _PostCard(
            avatar: '🧑‍🌾',
            name: 'Rajendran',
            location: 'Selangor',
            time: '1d ago',
            title: 'Government fertiliser subsidy — new deadline',
            body: 'Reminder: subsidy application deadline extended to end of month. Apply through e-Pertanian portal.',
            likes: 67,
            replies: 23,
            tag: 'Announcement',
            tagColor: const Color(0xFF7C3AED),
            tagBg: const Color(0xFFF3E8FF),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌾 Ask an Expert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 6),
                const Text('Get personalised advice from certified agronomists. Book a 30-min consultation.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Book Consultation', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String avatar, name, location, time, title, body, tag;
  final Color tagColor, tagBg;
  final int likes, replies;

  const _PostCard({
    required this.avatar, required this.name, required this.location,
    required this.time, required this.title, required this.body,
    required this.tag, required this.tagColor, required this.tagBg,
    required this.likes, required this.replies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
            child: Center(child: Text(avatar, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text('$location • $time', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(20)),
            child: Text(tag, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('$likes', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('$replies', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Spacer(),
          Icon(Icons.share_outlined, size: 16, color: AppColors.textSecondary),
        ]),
      ]),
    );
  }
}
