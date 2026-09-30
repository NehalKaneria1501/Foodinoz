import 'recipe_model.dart' show RecipeLanguage;

class CookingStepModel {
  final int stepNumber;
  final String title;
  final String instruction;
  final String? masalaPouchNumber; // e.g. "P-08", "P-14", or null if regular step
  final int durationMinutes;
  final bool isCompleted;

  // Multilingual step details & scratch-to-advanced pro guidance
  final String? titleGujarati;
  final String? titleHindi;
  final String? instructionGujarati;
  final String? instructionHindi;
  final String? flameLevel; // 'Low', 'Medium', 'High', 'Simmer'
  final String? proTip; // Scratch to advanced pro chef secret tip
  final String? proTipGujarati;
  final String? proTipHindi;

  const CookingStepModel({
    required this.stepNumber,
    required this.title,
    required this.instruction,
    this.masalaPouchNumber,
    this.durationMinutes = 5,
    this.isCompleted = false,
    this.titleGujarati,
    this.titleHindi,
    this.instructionGujarati,
    this.instructionHindi,
    this.flameLevel,
    this.proTip,
    this.proTipGujarati,
    this.proTipHindi,
  });

  String getTitle([RecipeLanguage lang = RecipeLanguage.english]) {
    switch (lang) {
      case RecipeLanguage.gujarati:
        return (titleGujarati != null && titleGujarati!.isNotEmpty) ? titleGujarati! : title;
      case RecipeLanguage.hindi:
        return (titleHindi != null && titleHindi!.isNotEmpty) ? titleHindi! : title;
      case RecipeLanguage.english:
        return title;
    }
  }

  String getInstruction([RecipeLanguage lang = RecipeLanguage.english]) {
    switch (lang) {
      case RecipeLanguage.gujarati:
        return (instructionGujarati != null && instructionGujarati!.isNotEmpty) ? instructionGujarati! : instruction;
      case RecipeLanguage.hindi:
        return (instructionHindi != null && instructionHindi!.isNotEmpty) ? instructionHindi! : instruction;
      case RecipeLanguage.english:
        return instruction;
    }
  }

  String? getProTip([RecipeLanguage lang = RecipeLanguage.english]) {
    switch (lang) {
      case RecipeLanguage.gujarati:
        return proTipGujarati ?? proTip;
      case RecipeLanguage.hindi:
        return proTipHindi ?? proTip;
      case RecipeLanguage.english:
        return proTip;
    }
  }

  String getFlameLevelLabel([RecipeLanguage lang = RecipeLanguage.english]) {
    final level = flameLevel ?? 'Medium Flame';
    switch (lang) {
      case RecipeLanguage.gujarati:
        switch (level.toLowerCase()) {
          case 'low':
          case 'low flame':
            return '🔥 ધીમો તાપ (Low Flame)';
          case 'high':
          case 'high flame':
            return '🔥🔥🔥 તેજ તાપ (High Flame)';
          case 'simmer':
            return '🍲 ધીમી આંચે ઉકાળો (Simmer)';
          case 'medium':
          case 'medium flame':
          default:
            return '🔥🔥 મધ્યમ તાપ (Medium Flame)';
        }
      case RecipeLanguage.hindi:
        switch (level.toLowerCase()) {
          case 'low':
          case 'low flame':
            return '🔥 धीमी आंच (Low Flame)';
          case 'high':
          case 'high flame':
            return '🔥🔥🔥 तेज आंच (High Flame)';
          case 'simmer':
            return '🍲 धीमी आंच पर पकाएं (Simmer)';
          case 'medium':
          case 'medium flame':
          default:
            return '🔥🔥 मध्यम आंच (Medium Flame)';
        }
      case RecipeLanguage.english:
        return '🔥 $level';
    }
  }

  CookingStepModel copyWith({
    int? stepNumber,
    String? title,
    String? instruction,
    String? masalaPouchNumber,
    int? durationMinutes,
    bool? isCompleted,
    String? titleGujarati,
    String? titleHindi,
    String? instructionGujarati,
    String? instructionHindi,
    String? flameLevel,
    String? proTip,
    String? proTipGujarati,
    String? proTipHindi,
  }) {
    return CookingStepModel(
      stepNumber: stepNumber ?? this.stepNumber,
      title: title ?? this.title,
      instruction: instruction ?? this.instruction,
      masalaPouchNumber: masalaPouchNumber ?? this.masalaPouchNumber,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      titleGujarati: titleGujarati ?? this.titleGujarati,
      titleHindi: titleHindi ?? this.titleHindi,
      instructionGujarati: instructionGujarati ?? this.instructionGujarati,
      instructionHindi: instructionHindi ?? this.instructionHindi,
      flameLevel: flameLevel ?? this.flameLevel,
      proTip: proTip ?? this.proTip,
      proTipGujarati: proTipGujarati ?? this.proTipGujarati,
      proTipHindi: proTipHindi ?? this.proTipHindi,
    );
  }
}
