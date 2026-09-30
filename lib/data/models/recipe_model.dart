import 'cooking_step_model.dart';
import 'ingredient_model.dart';

enum RecipeLanguage {
  english,
  gujarati,
  hindi,
}

extension RecipeLanguageExt on RecipeLanguage {
  String get code {
    switch (this) {
      case RecipeLanguage.english:
        return 'en';
      case RecipeLanguage.gujarati:
        return 'gu';
      case RecipeLanguage.hindi:
        return 'hi';
    }
  }

  String get displayName {
    switch (this) {
      case RecipeLanguage.english:
        return 'English';
      case RecipeLanguage.gujarati:
        return 'ગુજરાતી';
      case RecipeLanguage.hindi:
        return 'हिन्दी';
    }
  }

  String get shortLabel {
    switch (this) {
      case RecipeLanguage.english:
        return 'EN';
      case RecipeLanguage.gujarati:
        return 'GU';
      case RecipeLanguage.hindi:
        return 'HI';
    }
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

extension MealTypeExt on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String getLabel(RecipeLanguage lang) {
    switch (lang) {
      case RecipeLanguage.gujarati:
        switch (this) {
          case MealType.breakfast:
            return 'સવારનો નાસ્તો';
          case MealType.lunch:
            return 'બપોરનું ભોજન';
          case MealType.dinner:
            return 'સાંજનું ભોજન';
          case MealType.snack:
            return 'સાંજનો નાસ્તો';
        }
      case RecipeLanguage.hindi:
        switch (this) {
          case MealType.breakfast:
            return 'सुबह का नाश्ता';
          case MealType.lunch:
            return 'दोपहर का भोजन';
          case MealType.dinner:
            return 'रात का खाना';
          case MealType.snack:
            return 'शाम का नाश्ता';
        }
      case RecipeLanguage.english:
        return label;
    }
  }
}

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final String cuisine; // North Indian, South Indian, Gujarati, Jain, Swaminarayan, Thai, etc.
  final MealType mealType;
  final bool isVeg;
  final bool containsAsafoetida; // true = traditional Hing tempering, false = 100% Hing-Free / Satvik
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String masalaPouchNumber; // e.g. "P-08"
  final String pouchName; // e.g. "Royal Shahi Blend"
  final List<IngredientModel> ingredients;
  final List<CookingStepModel> steps;
  final String imageUrl;
  final double rating;

  // Multilingual Fields (English, Gujarati, Hindi)
  final String? titleGujarati;
  final String? titleHindi;
  final String? descriptionGujarati;
  final String? descriptionHindi;

  const RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cuisine,
    required this.mealType,
    required this.isVeg,
    this.containsAsafoetida = true,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.masalaPouchNumber,
    required this.pouchName,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    this.rating = 4.8,
    this.titleGujarati,
    this.titleHindi,
    this.descriptionGujarati,
    this.descriptionHindi,
  });

  bool get isHingFree => !containsAsafoetida;

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

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

  String getDescription([RecipeLanguage lang = RecipeLanguage.english]) {
    switch (lang) {
      case RecipeLanguage.gujarati:
        return (descriptionGujarati != null && descriptionGujarati!.isNotEmpty) ? descriptionGujarati! : description;
      case RecipeLanguage.hindi:
        return (descriptionHindi != null && descriptionHindi!.isNotEmpty) ? descriptionHindi! : description;
      case RecipeLanguage.english:
        return description;
    }
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? cuisine,
    MealType? mealType,
    bool? isVeg,
    bool? containsAsafoetida,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? masalaPouchNumber,
    String? pouchName,
    List<IngredientModel>? ingredients,
    List<CookingStepModel>? steps,
    String? imageUrl,
    double? rating,
    String? titleGujarati,
    String? titleHindi,
    String? descriptionGujarati,
    String? descriptionHindi,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cuisine: cuisine ?? this.cuisine,
      mealType: mealType ?? this.mealType,
      isVeg: isVeg ?? this.isVeg,
      containsAsafoetida: containsAsafoetida ?? this.containsAsafoetida,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      masalaPouchNumber: masalaPouchNumber ?? this.masalaPouchNumber,
      pouchName: pouchName ?? this.pouchName,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      titleGujarati: titleGujarati ?? this.titleGujarati,
      titleHindi: titleHindi ?? this.titleHindi,
      descriptionGujarati: descriptionGujarati ?? this.descriptionGujarati,
      descriptionHindi: descriptionHindi ?? this.descriptionHindi,
    );
  }
}
