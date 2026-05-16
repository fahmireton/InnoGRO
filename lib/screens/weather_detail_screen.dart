import 'package:flutter/material.dart';
import '../theme.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

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
              'Weather Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── LOCATION HEADER ────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text(
                      'Sekinchan, Selangor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    const Text(
                      'Updated 5 min ago',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── CURRENT CONDITIONS ─────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E4D6B), Color(0xFF2D6E96)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '30°C',
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text('☁️', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Cloudy',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Feels like 34°C',
                                style: TextStyle(fontSize: 13, color: Colors.white60),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'H:30°  L:26°',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _metricColumn('💧', '76%', 'Humidity'),
                            _verticalDivider(),
                            _metricColumn('💨', '9 km/h', 'Wind'),
                            _verticalDivider(),
                            _metricColumn('☀️', '6', 'UV Index'),
                            _verticalDivider(),
                            _metricColumn('👁️', '10 km', 'Visibility'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── 7-DAY FORECAST ─────────────────────────────────────
                _sectionLabel('7-DAY FORECAST'),
                Container(
                  decoration: _cardDecoration,
                  child: Column(
                    children: [
                      _forecastRow('Today', '☁️', '26°', '30°', 20, true),
                      const Divider(color: AppColors.divider, height: 1),
                      _forecastRow('Tue', '⛅', '25°', '31°', 15, false),
                      const Divider(color: AppColors.divider, height: 1),
                      _forecastRow('Wed', '🌧️', '24°', '28°', 75, false),
                      const Divider(color: AppColors.divider, height: 1),
                      _forecastRow('Thu', '🌧️', '23°', '27°', 80, false),
                      const Divider(color: AppColors.divider, height: 1),
                      _forecastRow('Fri', '☁️', '25°', '29°', 40, false),
                      const Divider(color: AppColors.divider, height: 1),
                      _forecastRow('Sat', '☀️', '27°', '33°', 5, false),
                      const Divider(color: AppColors.divider, height: 1),
                      _forecastRow('Sun', '☀️', '28°', '34°', 5, false),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── FARMING IMPACT ─────────────────────────────────────
                _sectionLabel('FARMING IMPACT'),
                Container(
                  decoration: _cardDecoration,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _farmingImpactRow(
                        Icons.coronavirus_rounded,
                        'Blast Risk',
                        'Moderate',
                        const Color(0xFFF59E0B),
                        const Color(0xFFFFF3CD),
                        'High humidity increases fungal spore germination',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      _farmingImpactRow(
                        Icons.air_rounded,
                        'Spray Window',
                        'Good',
                        AppColors.accent,
                        AppColors.accentLight,
                        'Low wind speed ideal for pesticide application',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      _farmingImpactRow(
                        Icons.water_rounded,
                        'Irrigation Need',
                        'Low',
                        AppColors.accent,
                        AppColors.accentLight,
                        'Rain forecasted — reduce irrigation by 50%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── HOURLY FORECAST ────────────────────────────────────
                _sectionLabel('HOURLY FORECAST'),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _hourCard('6 AM', '☁️', '26°'),
                      _hourCard('8 AM', '☁️', '27°'),
                      _hourCard('10 AM', '⛅', '28°'),
                      _hourCard('12 PM', '☀️', '30°'),
                      _hourCard('2 PM', '☀️', '30°'),
                      _hourCard('4 PM', '⛅', '29°'),
                      _hourCard('6 PM', '🌧️', '27°'),
                      _hourCard('8 PM', '🌧️', '26°'),
                      _hourCard('10 PM', '☁️', '25°'),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricColumn(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 50, color: Colors.white24);
  }

  Widget _forecastRow(
      String day, String emoji, String low, String high, int rainPct, bool isToday) {
    final rainColor = rainPct >= 60 ? AppColors.red : (rainPct >= 30 ? AppColors.amber : AppColors.accent);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, size: 12, color: Color(0xFF0369A1)),
              const SizedBox(width: 2),
              Text(
                '$rainPct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: rainColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Text(
            low,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          const Text('/', style: TextStyle(fontSize: 14, color: AppColors.divider)),
          const SizedBox(width: 4),
          Text(
            high,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _farmingImpactRow(
    IconData icon,
    String label,
    String status,
    Color badgeColor,
    Color badgeBg,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: badgeColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hourCard(String hour, String emoji, String temp) {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hour,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
