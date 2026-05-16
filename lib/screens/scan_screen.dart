import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../models/disease.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final List<String?> _images = [null, null, null];
  bool _analyzing = false;
  double _sliderValue = 0.5;
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (file != null && mounted) {
        final empty = _images.indexWhere((e) => e == null);
        if (empty != -1) setState(() => _images[empty] = file.path);
      }
    } catch (_) {}
  }

  Future<void> _diagnose() async {
    setState(() => _analyzing = true);
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;
    setState(() => _analyzing = false);
    final disease = mockDiseases[Random().nextInt(mockDiseases.length - 1)];
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(disease: disease)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        _buildContent(),
        if (_analyzing) _buildAnalyzing(),
      ]),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          const Text('AI Scan',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          const Text('Diagnose plant disease in seconds',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _uploadCard(),
          const SizedBox(height: 24),
          const Text('HEALTHY VS DISEASED',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _comparisonCard(),
        ],
      ),
    );
  }

  Widget _uploadCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image slots (3 x aspect-square)
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => _pick(ImageSource.gallery),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _images[i] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(Icons.image_rounded, size: 32, color: AppColors.accent),
                          )
                        : Icon(Icons.image_outlined, size: 32,
                            color: AppColors.textSecondary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 12),
          const Text('Add up to 3 angles for best accuracy.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          // Camera / Upload buttons
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pick(ImageSource.camera),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _pick(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.image_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 6),
                    Text('Upload', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          // Diagnose button — solid primary, rounded-full
          GestureDetector(
            onTap: _diagnose,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text('Diagnose with AI',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SizedBox(
            height: 200,
            child: Stack(children: [
              // Diseased side (right) — brown/orange
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFE8B88A)],
                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Healthy side (left) — overlays the left portion
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _sliderValue,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF95D5A8), Color(0xFFB7E4C7)],
                        begin: Alignment.centerLeft, end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),
              // Labels
              Positioned(left: 16, bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Healthy',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                )),
              Positioned(right: 16, bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Diseased',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                )),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.secondary,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (v) => setState(() => _sliderValue = v),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text('Drag to compare visual cues',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
      ]),
    );
  }

  Widget _buildAnalyzing() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Rotating scan icon in circle
            AnimatedBuilder(
              animation: _rotCtrl,
              builder: (_, child) => Transform.rotate(
                angle: _rotCtrl.value * 2 * pi,
                child: child,
              ),
              child: Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.document_scanner_rounded,
                  color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Analysing your crop...',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.3)),
            const SizedBox(height: 8),
            const Text('AI scanning for 50+ rice diseases',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]),
        ),
      ),
    );
  }
}
