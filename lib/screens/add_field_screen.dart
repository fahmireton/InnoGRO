import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';

const Map<String, List<String>> _myLocations = {
  'Kedah': [
    'Kota Setar', 'Kuala Muda', 'Pendang', 'Padang Terap',
    'Kubang Pasu', 'Baling', 'Sik', 'Yan', 'Bandar Baharu', 'Pokok Sena',
  ],
  'Perlis': ['Kangar', 'Arau', 'Padang Besar', 'Kaki Bukit'],
  'Kelantan': [
    'Kota Bharu', 'Pasir Mas', 'Tumpat', 'Machang',
    'Tanah Merah', 'Pasir Puteh', 'Bachok', 'Gua Musang', 'Kuala Krai',
  ],
  'Terengganu': [
    'Kuala Terengganu', 'Besut', 'Dungun', 'Kemaman', 'Hulu Terengganu', 'Setiu',
  ],
  'Perak': [
    'Kerian', 'Larut Matang', 'Hilir Perak', 'Kuala Kangsar',
    'Manjung', 'Batang Padang', 'Kinta',
  ],
  'Selangor': [
    'Sabak Bernam', 'Kuala Selangor', 'Hulu Selangor',
    'Kuala Langat', 'Sepang', 'Klang', 'Petaling',
  ],
  'Pahang': ['Pekan', 'Temerloh', 'Maran', 'Bera', 'Rompin', 'Kuantan'],
  'Johor': [
    'Batu Pahat', 'Muar', 'Pontian', 'Johor Bahru',
    'Kluang', 'Segamat', 'Mersing', 'Kota Tinggi',
  ],
  'Negeri Sembilan': [
    'Jelebu', 'Kuala Pilah', 'Rembau', 'Tampin', 'Port Dickson', 'Seremban',
  ],
  'Melaka': ['Alor Gajah', 'Jasin', 'Melaka Tengah'],
  'Pulau Pinang': [
    'Seberang Perai Utara', 'Seberang Perai Tengah', 'Seberang Perai Selatan',
  ],
  'Sarawak': [
    'Kota Samarahan', 'Samarahan', 'Kuching', 'Sibu',
    'Mukah', 'Miri', 'Bintulu', 'Sri Aman',
  ],
  'Sabah': [
    'Kota Belud', 'Tuaran', 'Kota Kinabalu', 'Beaufort',
    'Kudat', 'Tawau', 'Sandakan', 'Keningau', 'Ranau',
  ],
};

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cropCtrl = TextEditingController(text: 'Paddy (MR219)');
  final _areaCtrl = TextEditingController(text: '1');
  DateTime _plantedOn = DateTime.now();
  String? _selectedState;
  String? _selectedDistrict;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cropCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantedOn,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _plantedOn = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a state'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final area = double.tryParse(_areaCtrl.text) ?? 1.0;
    final cropRaw = _cropCtrl.text.trim();
    final variety = RegExp(r'\(([^)]+)\)').firstMatch(cropRaw)?.group(1) ?? cropRaw;
    final location = _selectedDistrict != null
        ? '$_selectedDistrict, $_selectedState'
        : _selectedState!;
    Navigator.pop(
      context,
      PaddyField(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        location: location,
        areaMorgen: area,
        stage: GrowthStage.seedling,
        healthStatus: HealthStatus.healthy,
        waterLevel: 50,
        fertilizerLevel: 50,
        healthScore: 80,
        plantedDate: _plantedOn,
        activityLog: ['Field added'],
        scanHistory: [],
        variety: variety.isNotEmpty ? variety : 'MR219',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('New field',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 20),

                  // NAME
                  _label('NAME'),
                  const SizedBox(height: 6),
                  _field(_nameCtrl, 'North Plot'),
                  const SizedBox(height: 14),

                  // CROP
                  _label('CROP'),
                  const SizedBox(height: 6),
                  _field(_cropCtrl, 'Paddy (MR219)', required: false),
                  const SizedBox(height: 14),

                  // SIZE + PLANTED ON
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('SIZE (ACRES)'),
                            const SizedBox(height: 6),
                            _field(_areaCtrl, '1', isNumber: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('PLANTED ON'),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: context.secondary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(children: [
                                  Expanded(
                                    child: Text(
                                      '${_plantedOn.day.toString().padLeft(2, '0')}/${_plantedOn.month.toString().padLeft(2, '0')}/${_plantedOn.year}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: context.textPrimary),
                                    ),
                                  ),
                                  Icon(Icons.calendar_today_rounded,
                                      size: 15,
                                      color: context.textSecondary),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // STATE
                  _label('STATE'),
                  const SizedBox(height: 6),
                  _dropdown(
                    value: _selectedState,
                    hint: 'Select state',
                    items: _myLocations.keys.toList()..sort(),
                    onChanged: (v) => setState(() {
                      _selectedState = v;
                      _selectedDistrict = null;
                    }),
                  ),
                  const SizedBox(height: 14),

                  // DISTRICT
                  _label('DISTRICT'),
                  const SizedBox(height: 6),
                  _dropdown(
                    value: _selectedDistrict,
                    hint: _selectedState == null
                        ? 'Select state first'
                        : 'Select district',
                    items: _selectedState != null
                        ? (_myLocations[_selectedState!] ?? [])
                        : [],
                    onChanged: _selectedState == null
                        ? null
                        : (v) => setState(() => _selectedDistrict = v),
                  ),
                  const SizedBox(height: 28),

                  // Buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: context.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: context.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save field',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.textSecondary,
            letterSpacing: 0.5),
      );

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.secondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(hint,
                style: TextStyle(
                    color: context.textSecondary.withValues(alpha: 0.6),
                    fontSize: 14)),
            style: TextStyle(fontSize: 14, color: context.textPrimary),
            dropdownColor: context.card,
            borderRadius: BorderRadius.circular(14),
            icon: Icon(Icons.expand_more_rounded,
                color: context.textSecondary, size: 20),
            items: items
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 14, color: context.textPrimary)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    bool required = true,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: TextStyle(fontSize: 14, color: context.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: context.textSecondary.withValues(alpha: 0.6)),
          filled: true,
          fillColor: context.secondary,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: required
            ? (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (isNumber && double.tryParse(v) == null) return 'Invalid';
                return null;
              }
            : null,
      );
}
