import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/widgets/pouch_badge.dart';
import '../../../../data/models/recipe_model.dart';
import '../../../../data/repositories/meal_plan_repository.dart';
import '../../shopping_list/views/shopping_list_screen.dart';
import '../view_models/meal_planner_view_model.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  @override
  Widget build(BuildContext context) {
    final plannerVm = context.watch<MealPlannerViewModel>();
    final plan = plannerVm.plan;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('MEAL SCHEDULE & RECIPES'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
            tooltip: 'Reset to AI Suggested Plan',
            onPressed: () => plannerVm.changeDuration(plannerVm.selectedDuration),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          border: Border(top: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder, width: 1)),
        ),
        child: BrutalistButton(
          text: 'Generate Combined Shopping List',
          isFullWidth: true,
          icon: const Icon(Icons.shopping_cart_checkout, size: 18, color: Colors.white),
          onPressed: () async {
            await plannerVm.generateShoppingList();
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ShoppingListScreen(),
                ),
              );
            }
          },
        ),
      ),
      body: plannerVm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Duration Switcher Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: isDark ? AppColors.surfaceContainer : AppColors.lightSurfaceWarm,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'PLAN HORIZON:',
                          style: AppTypography.metadata.copyWith(
                            color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [7, 15, 30].map((days) {
                          final isSelected = plannerVm.selectedDuration == days;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: InkWell(
                              onTap: () => plannerVm.changeDuration(days),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceBlack : Colors.white),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '$days D',
                                  style: AppTypography.labelButton.copyWith(
                                    color: isSelected ? Colors.white : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Divider(color: isDark ? AppColors.gridLine : AppColors.lightBorder, height: 1),

                // Daily Plan List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: plan.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final day = plan[index];
                      return _DayPlanCard(
                        day: day,
                        onSwapLunch: () => _openSwapSheet(
                          context,
                          plannerVm,
                          dayNumber: day.dayNumber,
                          isLunch: true,
                          currentRecipe: day.lunchRecipe,
                        ),
                        onSwapDinner: () => _openSwapSheet(
                          context,
                          plannerVm,
                          dayNumber: day.dayNumber,
                          isLunch: false,
                          currentRecipe: day.dinnerRecipe,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _openSwapSheet(
    BuildContext context,
    MealPlannerViewModel vm, {
    required int dayNumber,
    required bool isLunch,
    required RecipeModel currentRecipe,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: isDark ? AppColors.surfaceContainer : AppColors.lightSurfaceWarm,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'SWAP ${isLunch ? 'LUNCH' : 'DINNER'} (DAY $dayNumber)',
                        style: AppTypography.headlineSm.copyWith(
                          color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(color: isDark ? AppColors.gridLine : AppColors.lightBorder, height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: vm.allAvailableRecipes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, idx) {
                    final rec = vm.allAvailableRecipes[idx];
                    final isCurrent = rec.id == currentRecipe.id;

                    return BrutalistCard(
                      borderColor: isCurrent ? AppColors.primary : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                      backgroundColor: isCurrent 
                          ? (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm) 
                          : (isDark ? AppColors.surfaceContainer : Colors.white),
                      onTap: () {
                        vm.swapRecipe(
                          dayNumber: dayNumber,
                          isLunch: isLunch,
                          newRecipe: rec,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Swapped to ${rec.title} for Day $dayNumber')),
                        );
                      },
                      child: Row(
                        children: [
                          PouchBadge(pouchNumber: rec.masalaPouchNumber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.title, 
                                  style: AppTypography.headlineSm.copyWith(
                                    fontSize: 15,
                                    color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${rec.cuisine} • ${rec.totalTimeMinutes} mins',
                                  style: AppTypography.bodySm.copyWith(
                                    color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            const Text('ACTIVE', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                          else
                            const Icon(Icons.swap_horiz, color: AppColors.secondaryOrange),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayPlanCard extends StatefulWidget {
  final PlannedDay day;
  final VoidCallback onSwapLunch;
  final VoidCallback onSwapDinner;

  const _DayPlanCard({
    required this.day,
    required this.onSwapLunch,
    required this.onSwapDinner,
  });

  @override
  State<_DayPlanCard> createState() => _DayPlanCardState();
}

class _DayPlanCardState extends State<_DayPlanCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrutalistCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'DAY ${widget.day.dayNumber} // ${widget.day.dayName.toUpperCase()}',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 13, 
                      letterSpacing: 1,
                      color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.day.date.day}/${widget.day.date.month}',
                  style: AppTypography.metadata.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? AppColors.gridLine : AppColors.lightBorder, height: 1),

          // Lunch Slot
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
                  child: Text(
                    'LUNCH', 
                    style: AppTypography.metadata.copyWith(
                      color: isDark ? AppColors.onSurface : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PouchBadge(pouchNumber: widget.day.lunchRecipe.masalaPouchNumber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.day.lunchRecipe.title,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: AppColors.secondaryOrange, size: 20),
                  tooltip: 'Swap lunch recipe',
                  onPressed: widget.onSwapLunch,
                ),
              ],
            ),
          ),
          Divider(indent: 14, endIndent: 14, color: isDark ? AppColors.gridLine : AppColors.lightBorder, height: 1),

          // Dinner Slot
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
                  child: Text(
                    'DINNER', 
                    style: AppTypography.metadata.copyWith(
                      color: isDark ? AppColors.onSurface : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PouchBadge(pouchNumber: widget.day.dinnerRecipe.masalaPouchNumber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.day.dinnerRecipe.title,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: AppColors.secondaryOrange, size: 20),
                  tooltip: 'Swap dinner recipe',
                  onPressed: widget.onSwapDinner,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
