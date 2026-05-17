import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../services/scan_service.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final List<XFile?> _images = [null, null, null];
  bool _analyzing = false;
  double _sliderValue = 0.5;
  int _analyzeStep = 0;
  Timer? _stepTimer;
  late AnimationController _rotCtrl;

  static const _analyzeMessages = [
    'Uploading your image…',
    'Analysing with AI…',
    'Preparing diagnosis results…',
  ];

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _rotCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (file != null && mounted) {
        final empty = _images.indexWhere((e) => e == null);
        final idx = empty != -1 ? empty : 0;
        setState(() => _images[idx] = file);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not open image picker. Try again.'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _diagnose() async {
    final xfiles = _images.whereType<XFile>().toList();
    if (xfiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please add at least one photo first.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() { _analyzing = true; _analyzeStep = 0; });
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1600), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { if (_analyzeStep < 2) _analyzeStep++; });
    });
    try {
      final disease = await ScanService.analyzeXFiles(xfiles);
      _stepTimer?.cancel();
      if (!mounted) return;
      setState(() => _analyzing = false);
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(disease: disease, images: xfiles)));
      if (mounted) setState(() => _images.fillRange(0, 3, null));
    } catch (e) {
      _stepTimer?.cancel();
      if (!mounted) return;
      setState(() => _analyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Analysis failed: $e'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
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
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
        children: [
          Text('PaddyIntelligence',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _comparisonCard(context),
          ),
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
                  onTap: () => _showPickerSheet(i),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _images[i] != null
                            ? AppColors.accent.withValues(alpha: 0.5)
                            : context.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: _images[i] != null
                        ? Stack(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: kIsWeb
                                ? Image.network(
                                    _images[i]!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 32),
                                  )
                                : Image.file(
                                    File(_images[i]!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                            ),
                            Positioned(
                              top: 4, right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _images[i] = null),
                                child: Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                                ),
                              ),
                            ),
                          ])
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 28,
                                color: context.textSecondary.withValues(alpha: 0.5)),
                            const SizedBox(height: 4),
                            Text('Photo ${i + 1}', style: TextStyle(fontSize: 10, color: context.textSecondary.withValues(alpha: 0.5))),
                          ]),
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
            onTap: _images.every((e) => e == null) ? null : _diagnose,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _images.every((e) => e == null)
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: _images.every((e) => e == null) ? [] : [
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

  void _showPickerSheet(int slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Add Photo', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              ),
              title: Text('Take Photo', style: TextStyle(
                fontWeight: FontWeight.w600, color: context.textPrimary)),
              subtitle: Text('Use camera', style: TextStyle(
                fontSize: 12, color: context.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickSlot(slot, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
              ),
              title: Text('Choose from Gallery', style: TextStyle(
                fontWeight: FontWeight.w600, color: context.textPrimary)),
              subtitle: Text('Select from photos', style: TextStyle(
                fontSize: 12, color: context.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickSlot(slot, ImageSource.gallery);
              },
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickSlot(int slot, ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (file != null && mounted) {
        setState(() => _images[slot] = file);
      }
    } catch (_) {}
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
                  child: Image.asset('assets/images/paddy_diseased2.png', fit: BoxFit.cover),
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
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              AppColors.primary.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Pulsing + Rotating scan icon
              AnimatedBuilder(
                animation: _rotCtrl,
                builder: (_, child) {
                  final pulseScale = 1.0 + (sin(_rotCtrl.value * 4 * pi) * 0.1);
                  return Transform.scale(
                    scale: pulseScale,
                    child: Transform.rotate(
                      angle: _rotCtrl.value * 2 * pi,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.primary,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.6),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.document_scanner_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Step message with fade animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  _analyzeMessages[_analyzeStep],
                  key: ValueKey(_analyzeStep),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'AI-powered paddy disease diagnosis',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Progress dots with glow
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final isActive = i == _analyzeStep;
                  final isDone = i < _analyzeStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDone || isActive
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: (isDone || isActive)
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
