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
      backgroundColor: context.bg,
      body: Stack(children: [
        _buildContent(context),
        if (_analyzing) _buildAnalyzing(),
      ]),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          Text('AI Scan',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
              color: context.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text('Diagnose plant disease in seconds',
            style: TextStyle(fontSize: 14, color: context.textSecondary)),
          const SizedBox(height: 20),
          _uploadCard(context),
          const SizedBox(height: 24),
          Text('HEALTHY VS DISEASED',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: context.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _comparisonCard(context),
        ],
      ),
    );
  }

  Widget _uploadCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border.withValues(alpha: 0.4)),
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
                        color: context.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _images[i] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(Icons.image_rounded, size: 32, color: AppColors.accent),
                          )
                        : Icon(Icons.image_outlined, size: 32,
                            color: context.textSecondary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 12),
          Text('Add up to 3 angles for best accuracy.',
            style: TextStyle(fontSize: 13, color: context.textSecondary)),
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
                    color: context.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.image_outlined, size: 18, color: context.textPrimary),
                    const SizedBox(width: 6),
                    Text('Upload', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600)),
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

  Widget _comparisonCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image comparison slider
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 210,
              child: Stack(children: [
                // Diseased paddy — full background
                SizedBox(
                  width: w, height: 210,
                  child: Image.asset('assets/images/paddy_diseased.png', fit: BoxFit.cover),
                ),
                // Healthy paddy — clipped to left slider fraction
                ClipRect(
                  child: SizedBox(
                    width: w * _sliderValue, height: 210,
                    child: OverflowBox(
                      maxWidth: w,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: w, height: 210,
                        child: Image.asset('assets/images/paddy_healthy.png', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                // Divider line at slider position
                Positioned(
                  left: w * _sliderValue - 1,
                  top: 0, bottom: 0,
                  child: Container(width: 2, color: Colors.white),
                ),
                // Handle circle on divider
                Positioned(
                  left: w * _sliderValue - 16,
                  top: 0, bottom: 0,
                  child: Center(
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)],
                      ),
                      child: const Icon(Icons.compare_arrows_rounded, size: 18, color: AppColors.primary),
                    ),
                  ),
                ),
                // Labels
                Positioned(left: 12, bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Healthy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  )),
                Positioned(right: 12, bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Diseased', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  )),
              ]),
            );
          }),
        ),
        // Slider control
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: context.secondary,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Slider(value: _sliderValue, onChanged: (v) => setState(() => _sliderValue = v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Center(child: Text('Drag to compare visual cues',
            style: TextStyle(fontSize: 12, color: context.textSecondary))),
        ),
        // Factual info section
        Divider(height: 1, color: context.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Healthy column
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Healthy Paddy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ]),
              const SizedBox(height: 8),
              ...[
                'Deep, uniform green leaves',
                'Upright & turgid leaf blades',
                '5–8 cm standing water depth',
                'No spots or discoloration',
                '5–7 tillers per plant',
              ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('• ', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                  Expanded(child: Builder(builder: (ctx) => Text(s, style: TextStyle(fontSize: 12, color: ctx.textSecondary, height: 1.3)))),
                ]),
              )),
            ])),
            const SizedBox(width: 12),
            Container(width: 1, height: 120, color: context.border),
            const SizedBox(width: 12),
            // Diseased column
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Diseased Paddy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.red)),
              ]),
              const SizedBox(height: 8),
              ...[
                'Yellowing from leaf tips & edges',
                'Brown lesions or water-soaked spots',
                'Drooping or wilting leaves',
                'Stunted & uneven plant height',
                'Early senescence & poor tillering',
              ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('• ', style: TextStyle(fontSize: 12, color: AppColors.red)),
                  Expanded(child: Builder(builder: (ctx) => Text(s, style: TextStyle(fontSize: 12, color: ctx.textSecondary, height: 1.3)))),
                ]),
              )),
            ])),
          ]),
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
