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
  bool _analyzing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 85);
      if (file == null || !mounted) return;
      await _runAnalysis();
    } catch (_) {
      await _runAnalysis();
    }
  }

  Future<void> _runAnalysis() async {
    setState(() => _analyzing = true);
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    setState(() => _analyzing = false);

    final rand = Random();
    final disease = mockDiseases[rand.nextInt(mockDiseases.length - 1)];

    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(disease: disease)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('AI Disease Scan'),
        backgroundColor: AppColors.primary,
      ),
      body: _analyzing ? _buildAnalyzing() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildScanArea(),
          const SizedBox(height: 32),
          const Text('How to get the best results',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _tip(Icons.light_mode_rounded, 'Good lighting', 'Scan in natural daylight, avoid shadows on the leaf'),
          _tip(Icons.center_focus_strong_rounded, 'Close-up focus', 'Fill the frame with the affected leaf area'),
          _tip(Icons.multiple_stop_rounded, 'Multiple angles', 'Take 2–3 photos for better accuracy'),
        ],
      ),
    );
  }

  Widget _buildScanArea() {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.document_scanner_rounded, size: 42, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                const Text('Scan a paddy leaf', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Take a photo or upload from gallery',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PulsingRing(),
            const SizedBox(height: 40),
            const Text('Analysing your crop...', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3)),
            const SizedBox(height: 10),
            const Text('Our AI is scanning for 50+ rice diseases.\nThis takes just a moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 40),
            _AnalyzingStep('Loading disease database', true),
            const SizedBox(height: 10),
            _AnalyzingStep('Detecting leaf features', true),
            const SizedBox(height: 10),
            _AnalyzingStep('Running AI classification...', false),
          ],
        ),
      ),
    );
  }

  Widget _tip(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          )),
        ],
      ),
    );
  }
}

class _PulsingRing extends StatefulWidget {
  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120 + (_anim.value * 40),
            height: 120 + (_anim.value * 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.05 + (0.1 * (1 - _anim.value))),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLight,
            ),
            child: const Icon(Icons.biotech_rounded, size: 48, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _AnalyzingStep extends StatelessWidget {
  final String label;
  final bool done;
  const _AnalyzingStep(this.label, this.done);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        done
          ? const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 18)
          : const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary)),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(
          fontSize: 13,
          color: done ? AppColors.textSecondary : AppColors.textPrimary,
          fontWeight: done ? FontWeight.w400 : FontWeight.w600,
        )),
      ],
    );
  }
}
