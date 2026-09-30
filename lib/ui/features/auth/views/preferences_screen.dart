import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../data/models/user_model.dart';
import '../../../navigation/main_navigation_shell.dart';
import '../view_models/auth_view_model.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  DietaryPreference _dietary = DietaryPreference.vegetarian;
  AsafoetidaPreference _asafoetida = AsafoetidaPreference.withAsafoetida;
  final Set<String> _selectedCuisines = {'North Indian', 'South Indian'};
  final Set<String> _mealTypes = {'Lunch', 'Dinner'};
  int _familyCount = 3;

  final List<String> _availableCuisines = [
    'North Indian',
    'South Indian',
    'Gujarati',
    'Jain',
    'Swaminarayan',
    'Continental',
    'Pan Asian',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    if (user != null) {
      _dietary = user.dietaryPreference;
      _asafoetida = user.asafoetidaPreference;
      _familyCount = user.familyMembersCount;
      _selectedCuisines.clear();
      _selectedCuisines.addAll(user.preferredCuisines);
      _mealTypes.clear();
      _mealTypes.addAll(user.mealPreferences);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('DIETARY PREFERENCES'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customize Your Meal Experience',
                style: AppTypography.headlineLg,
              ),
              const SizedBox(height: 6),
              Text(
                'Jeerola tailors your 7/15/30-day shopping lists and recipe suggestions to your household.',
                style: AppTypography.bodySm,
              ),
              const SizedBox(height: 24),

              // Dietary Preference
              Text('DIETARY TYPE', style: AppTypography.metadata),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DietaryPreference.values.map((pref) {
                  final isSelected = _dietary == pref;
                  return InkWell(
                    onTap: () => setState(() => _dietary = pref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary 
                            : (isDark ? AppColors.surfaceContainer : Colors.white),
                        border: Border.all(
                          color: isSelected ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        pref.label,
                        style: AppTypography.labelButton.copyWith(
                          color: isSelected ? Colors.white : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Asafoetida / Hing Preference
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ASAFOETIDA / HING (હીંગ)', style: AppTypography.metadata),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                    child: Text(
                      _asafoetida == AsafoetidaPreference.withoutAsafoetida ? 'STRICT SATVIK / JAIN' : 'STANDARD SPICE',
                      style: AppTypography.metadata.copyWith(
                        color: _asafoetida == AsafoetidaPreference.withoutAsafoetida ? AppColors.sproutGreen : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: AsafoetidaPreference.values.map((pref) {
                  final isSelected = _asafoetida == pref;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: pref == AsafoetidaPreference.values.first ? 8.0 : 0.0),
                      child: InkWell(
                        onTap: () => setState(() => _asafoetida = pref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary 
                                : (isDark ? AppColors.surfaceContainer : Colors.white),
                            border: Border.all(
                              color: isSelected ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                pref.label,
                                textAlign: TextAlign.center,
                                style: AppTypography.labelButton.copyWith(
                                  color: isSelected ? Colors.white : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pref == AsafoetidaPreference.withoutAsafoetida
                                    ? 'Zero Hing • Satvik Tadka'
                                    : 'Aromatic Hing • Traditional Tadka',
                                textAlign: TextAlign.center,
                                style: AppTypography.metadata.copyWith(
                                  color: isSelected 
                                      ? Colors.white70 
                                      : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Cuisines
              Text('PREFERRED CUISINES', style: AppTypography.metadata),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCuisines.map((cuisine) {
                  final isSelected = _selectedCuisines.contains(cuisine);
                  return FilterChip(
                    label: Text(cuisine),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCuisines.add(cuisine);
                        } else if (_selectedCuisines.length > 1) {
                          _selectedCuisines.remove(cuisine);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                    ),
                    backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    selectedColor: isDark ? AppColors.primaryContainer : const Color(0xFFFFECE5),
                    labelStyle: AppTypography.bodySm.copyWith(
                      color: isSelected 
                          ? (isDark ? AppColors.onPrimaryContainer : AppColors.primaryDark) 
                          : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Family Members Count
              Text('HOUSEHOLD / SERVINGS COUNT', style: AppTypography.metadata),
              const SizedBox(height: 8),
              BrutalistCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Family Members', style: AppTypography.bodyMd),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.remove,
                            color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                          ),
                          onPressed: _familyCount > 1 ? () => setState(() => _familyCount--) : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceBlack : AppColors.lightSurfaceWarm,
                            border: Border.all(
                              color: isDark ? Colors.transparent : AppColors.lightBorder,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_familyCount',
                            style: AppTypography.numericData.copyWith(
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppColors.primary),
                          onPressed: _familyCount < 10 ? () => setState(() => _familyCount++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              BrutalistButton(
                text: 'Save & Launch Kitchen OS',
                isFullWidth: true,
                isLoading: authVm.isLoading,
                onPressed: () async {
                  await authVm.savePreferences(
                    preference: _dietary,
                    asafoetida: _asafoetida,
                    cuisines: _selectedCuisines.toList(),
                    meals: _mealTypes.toList(),
                    familyCount: _familyCount,
                  );
                  if (context.mounted) {
                    AppToast.success(
                      'Preferences saved! Welcome to Jeerola Kitchen OS.',
                      isDark: isDark,
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
