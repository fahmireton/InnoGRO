import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  GrowthStage _stage = GrowthStage.seedling;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, PaddyField(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      areaMorgen: double.parse(_areaCtrl.text),
      stage: _stage,
      healthStatus: HealthStatus.healthy,
      waterLevel: 50,
      fertilizerLevel: 50,
      healthScore: 80,
      plantedDate: DateTime.now(),
      activityLog: ['🌱 Field added to VisionGRO'],
      scanHistory: [],
      variety: 'MR219',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Add New Field',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _input(context, 'Field Name', 'e.g. Sawah Timur', _nameCtrl),
            const SizedBox(height: 14),
            _input(context, 'Location', 'e.g. Kedah, Malaysia', _locationCtrl),
            const SizedBox(height: 14),
            _input(context, 'Area (morgen)', 'e.g. 2.5', _areaCtrl, isNumber: true),
            const SizedBox(height: 24),
            Text('Current Growth Stage',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                color: context.textPrimary)),
            const SizedBox(height: 12),
            ...GrowthStage.values.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _stage = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _stage == s ? AppColors.accentLight : context.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _stage == s ? AppColors.primary : context.border,
                      width: _stage == s ? 2 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Text(s.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.label, style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14,
                          color: _stage == s ? AppColors.primary : context.textPrimary)),
                        Text(s.dayRange,
                          style: TextStyle(fontSize: 11, color: context.textSecondary)),
                      ],
                    )),
                    if (_stage == s)
                      const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
                  ]),
                ),
              ),
            )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Add Field',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(BuildContext context, String label, String hint, TextEditingController ctrl, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
          color: context.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.textSecondary),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'This field is required';
            if (isNumber && double.tryParse(v) == null) return 'Enter a valid number';
            return null;
          },
        ),
      ],
    );
  }
}
