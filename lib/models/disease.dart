class Disease {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String severity;
  final double confidence;
  final List<String> symptoms;
  final List<String> causes;
  final List<Treatment> organicTreatments;
  final List<Treatment> chemicalTreatments;
  final List<String> prevention;
  final String recoveryTime;
  final String affectedArea;

  const Disease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.severity,
    required this.confidence,
    required this.symptoms,
    required this.causes,
    required this.organicTreatments,
    required this.chemicalTreatments,
    required this.prevention,
    required this.recoveryTime,
    required this.affectedArea,
  });
}

class Treatment {
  final String name;
  final String instructions;
  final String estimatedCost;
  final int effectivenessRating;

  const Treatment({
    required this.name,
    required this.instructions,
    required this.estimatedCost,
    required this.effectivenessRating,
  });
}

final List<Disease> mockDiseases = [
  Disease(
    id: 'blast',
    name: 'Rice Blast',
    scientificName: 'Magnaporthe oryzae',
    description: 'The most destructive rice disease worldwide. Affects leaves, nodes, necks and panicles causing significant yield losses up to 70% in severe cases.',
    severity: 'High',
    confidence: 94.2,
    symptoms: [
      'Diamond-shaped lesions with grey centres and brown borders',
      'White to grey-green lesions on leaves',
      'Rotting at the base of panicle neck',
      'Affected grains appear chalky or unfilled',
    ],
    causes: [
      'Fungal pathogen spread by wind-borne spores',
      'High humidity (>90%) and temperatures 25–28°C',
      'Excessive nitrogen fertilisation',
      'Dense planting with poor air circulation',
    ],
    organicTreatments: [
      Treatment(
        name: 'Silica Soil Amendment',
        instructions: 'Apply 200kg/ha of silica-rich slag to strengthen cell walls. Apply 2 weeks before expected infection.',
        estimatedCost: 'RM 80–120/ha',
        effectivenessRating: 3,
      ),
      Treatment(
        name: 'Trichoderma Bio-fungicide',
        instructions: 'Mix 5g Trichoderma per litre of water. Spray on leaves every 7 days. Apply in the early morning.',
        estimatedCost: 'RM 40–60/ha',
        effectivenessRating: 4,
      ),
    ],
    chemicalTreatments: [
      Treatment(
        name: 'Tricyclazole 75 WP',
        instructions: 'Mix 0.6g per litre of water. Spray 2–3 times at 10-day intervals. Wear PPE during application.',
        estimatedCost: 'RM 120–180/ha',
        effectivenessRating: 5,
      ),
      Treatment(
        name: 'Isoprothiolane',
        instructions: 'Apply 1.5ml per litre of water. Effective as both preventive and curative treatment.',
        estimatedCost: 'RM 100–150/ha',
        effectivenessRating: 5,
      ),
    ],
    prevention: [
      'Use blast-resistant varieties (MR219, MR263)',
      'Avoid excessive nitrogen fertiliser',
      'Maintain proper plant spacing (20x20cm)',
      'Remove infected plant debris after harvest',
      'Apply prophylactic fungicide at tillering stage',
    ],
    recoveryTime: '2–3 weeks with treatment',
    affectedArea: 'Leaves, neck, panicle',
  ),
  Disease(
    id: 'brownspot',
    name: 'Brown Spot',
    scientificName: 'Cochliobolus miyabeanus',
    description: 'A fungal disease affecting rice at all growth stages. Causes significant quality loss and grain discolouration, particularly in nutrient-deficient soils.',
    severity: 'Medium',
    confidence: 89.7,
    symptoms: [
      'Circular to oval brown lesions on leaves',
      'White or grey centres surrounded by brown borders',
      'Brown discolouration on glumes (grain covering)',
      'Seedling blight in severe cases',
    ],
    causes: [
      'Fungus Cochliobolus miyabeanus',
      'Nutrient deficiency, especially potassium and silicon',
      'Drought stress or waterlogged conditions',
      'Infected seed material',
    ],
    organicTreatments: [
      Treatment(
        name: 'Potassium Supplementation',
        instructions: 'Apply muriate of potash at 60kg K₂O/ha. Split application at basal and panicle initiation.',
        estimatedCost: 'RM 60–90/ha',
        effectivenessRating: 4,
      ),
    ],
    chemicalTreatments: [
      Treatment(
        name: 'Mancozeb 80 WP',
        instructions: 'Apply 2.5g per litre of water. Spray at 7–10 day intervals beginning at first sign of disease.',
        estimatedCost: 'RM 70–100/ha',
        effectivenessRating: 4,
      ),
    ],
    prevention: [
      'Use certified disease-free seed',
      'Seed treatment with fungicide before planting',
      'Maintain balanced soil nutrition',
      'Avoid water stress — maintain 5cm water level',
      'Use resistant varieties where available',
    ],
    recoveryTime: '1–2 weeks with treatment',
    affectedArea: 'Leaves, grains, seedlings',
  ),
  Disease(
    id: 'blight',
    name: 'Bacterial Leaf Blight',
    scientificName: 'Xanthomonas oryzae pv. oryzae',
    description: 'One of the most serious bacterial diseases of rice. Can cause complete crop failure in severe epidemics, particularly in irrigated areas.',
    severity: 'High',
    confidence: 91.5,
    symptoms: [
      'Water-soaked to yellowish stripes along leaf margins',
      'Lesions enlarge and turn yellow to white',
      'Leaves wilt and dry from tip to base',
      'Bacterial ooze visible in early morning (kresek phase)',
    ],
    causes: [
      'Bacterium spread through irrigation water and rain',
      'Wounds from strong winds or insects',
      'High temperatures (25–34°C) with high humidity',
      'Excessive nitrogen fertiliser application',
    ],
    organicTreatments: [
      Treatment(
        name: 'Copper Hydroxide Spray',
        instructions: 'Mix 3g copper hydroxide per litre. Spray on affected areas. Repeat after 7 days.',
        estimatedCost: 'RM 50–80/ha',
        effectivenessRating: 3,
      ),
    ],
    chemicalTreatments: [
      Treatment(
        name: 'Bismerthiazol + Validamycin',
        instructions: 'Mix as per label (typically 2ml/L). Apply at seedling and tillering stage. Most effective when applied early.',
        estimatedCost: 'RM 90–130/ha',
        effectivenessRating: 4,
      ),
    ],
    prevention: [
      'Plant resistant varieties (MR220 CL2, MR284)',
      'Avoid lodging — do not over-apply nitrogen',
      'Drain fields during outbreak to reduce spread',
      'Do not transplant from infected nurseries',
      'Clean farm tools and equipment regularly',
    ],
    recoveryTime: '3–4 weeks (bacterial diseases are harder to cure)',
    affectedArea: 'Leaves, vascular tissue',
  ),
  Disease(
    id: 'healthy',
    name: 'No Disease Detected',
    scientificName: '',
    description: 'Your crop appears healthy! No signs of disease were detected in this scan. Continue your current farming practices and monitor regularly.',
    severity: 'None',
    confidence: 97.1,
    symptoms: [],
    causes: [],
    organicTreatments: [],
    chemicalTreatments: [],
    prevention: [
      'Continue regular field monitoring every 3–5 days',
      'Maintain proper water levels (5–10cm)',
      'Apply balanced fertiliser as per crop stage',
      'Scout for pests during early morning hours',
      'Keep field records for future reference',
    ],
    recoveryTime: 'N/A',
    affectedArea: 'None',
  ),
];
