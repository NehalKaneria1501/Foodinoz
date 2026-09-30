import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/cooking_step_model.dart';
import '../../../../data/models/recipe_model.dart';
import '../../../../data/repositories/cooking_repository.dart';

class CookingViewModel extends ChangeNotifier {
  final RecipeModel recipe;
  final CookingRepository _cookingRepository;

  CookingViewModel({
    required this.recipe,
    required this._cookingRepository,
  })  : _steps = List.from(recipe.steps) {
    _initTimerForCurrentStep();
  }

  final List<CookingStepModel> _steps;
  int _currentStepIndex = 0;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;
  Timer? _timer;
  bool _isFinished = false;

  List<CookingStepModel> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  CookingStepModel get currentStep => _steps[_currentStepIndex];
  int get secondsRemaining => _secondsRemaining;
  bool get isTimerRunning => _isTimerRunning;
  bool get isFinished => _isFinished;

  double get stepProgress => (_currentStepIndex + 1) / _steps.length;

  void _initTimerForCurrentStep() {
    _secondsRemaining = currentStep.durationMinutes * 60;
  }

  void toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      _isTimerRunning = false;
    } else {
      _isTimerRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          notifyListeners();
        } else {
          _timer?.cancel();
          _isTimerRunning = false;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void nextStep() {
    _timer?.cancel();
    _isTimerRunning = false;

    if (_currentStepIndex < _steps.length - 1) {
      _currentStepIndex++;
      _initTimerForCurrentStep();
      notifyListeners();
    } else {
      // Completed all steps!
      _isFinished = true;
      _cookingRepository.completeCookingSession(recipe);
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStepIndex > 0) {
      _timer?.cancel();
      _isTimerRunning = false;
      _currentStepIndex--;
      _initTimerForCurrentStep();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
