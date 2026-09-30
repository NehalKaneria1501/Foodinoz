import '../models/recipe_model.dart';
import '../services/local_storage_service.dart';
import '../services/mock_data_service.dart';

class PlannedDay {
  final int dayNumber;
  final String dayName;
  final DateTime date;
  final RecipeModel lunchRecipe;
  final RecipeModel dinnerRecipe;

  PlannedDay({
    required this.dayNumber,
    required this.dayName,
    required this.date,
    required this.lunchRecipe,
    required this.dinnerRecipe,
  });

  PlannedDay copyWith({
    int? dayNumber,
    String? dayName,
    DateTime? date,
    RecipeModel? lunchRecipe,
    RecipeModel? dinnerRecipe,
  }) {
    return PlannedDay(
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      date: date ?? this.date,
      lunchRecipe: lunchRecipe ?? this.lunchRecipe,
      dinnerRecipe: dinnerRecipe ?? this.dinnerRecipe,
    );
  }
}

class MealPlanRepository {
  final LocalStorageService _localStorageService;
  final List<PlannedDay> _currentPlan = [];
  int _planDurationDays = 7;

  MealPlanRepository({required this._localStorageService}) {
    _planDurationDays = _localStorageService.activePlanDays;
    _generateDefaultPlan(_planDurationDays);
  }

  int get planDurationDays => _planDurationDays;

  List<PlannedDay> get currentPlan => List.unmodifiable(_currentPlan);

  void _generateDefaultPlan(int days) {
    _currentPlan.clear();
    final allRecipes = MockDataService.recipes;
    final now = DateTime.now();

    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (int i = 0; i < days; i++) {
      final date = now.add(Duration(days: i));
      final dayName = weekdays[(date.weekday - 1) % 7];

      // Auto-fill diverse default recipes cycling through curated list
      final lunch = allRecipes[(i * 2) % allRecipes.length];
      final dinner = allRecipes[(i * 2 + 1) % allRecipes.length];

      _currentPlan.add(
        PlannedDay(
          dayNumber: i + 1,
          dayName: dayName,
          date: date,
          lunchRecipe: lunch,
          dinnerRecipe: dinner,
        ),
      );
    }
  }

  Future<List<PlannedDay>> setPlanDuration(int days) async {
    _planDurationDays = days;
    _localStorageService.updatePlanDays(days);
    _generateDefaultPlan(days);
    return List.unmodifiable(_currentPlan);
  }

  Future<void> swapRecipe({
    required int dayNumber,
    required bool isLunch,
    required RecipeModel newRecipe,
  }) async {
    final index = _currentPlan.indexWhere((p) => p.dayNumber == dayNumber);
    if (index != -1) {
      final existing = _currentPlan[index];
      _currentPlan[index] = existing.copyWith(
        lunchRecipe: isLunch ? newRecipe : existing.lunchRecipe,
        dinnerRecipe: !isLunch ? newRecipe : existing.dinnerRecipe,
      );
    }
  }

  /// Extracts all active ingredients across the current plan
  List<RecipeModel> getAllPlannedRecipes() {
    final Set<String> ids = {};
    final List<RecipeModel> recipes = [];

    for (final day in _currentPlan) {
      if (ids.add(day.lunchRecipe.id)) {
        recipes.add(day.lunchRecipe);
      }
      if (ids.add(day.dinnerRecipe.id)) {
        recipes.add(day.dinnerRecipe);
      }
    }
    return recipes;
  }
}
