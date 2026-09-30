import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/widgets/pouch_badge.dart';
import '../../../../data/models/recipe_model.dart';
import '../../../../data/repositories/cooking_repository.dart';
import '../../../../core/utils/invoice_download_helper.dart';
import '../view_models/cooking_view_model.dart';
import 'cooking_reward_dialog.dart';

class CookingProtocolScreen extends StatefulWidget {
  final RecipeModel recipe;
  final RecipeLanguage initialLanguage;

  const CookingProtocolScreen({
    super.key,
    required this.recipe,
    this.initialLanguage = RecipeLanguage.english,
  });

  @override
  State<CookingProtocolScreen> createState() => _CookingProtocolScreenState();
}

class _CookingProtocolScreenState extends State<CookingProtocolScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CookingViewModel(
        recipe: widget.recipe,
        cookingRepository: ctx.read<CookingRepository>(),
      ),
      child: _CookingProtocolView(initialLanguage: widget.initialLanguage),
    );
  }
}

class _CookingProtocolView extends StatefulWidget {
  final RecipeLanguage initialLanguage;

  const _CookingProtocolView({this.initialLanguage = RecipeLanguage.english});

  @override
  State<_CookingProtocolView> createState() => _CookingProtocolViewState();
}

class _CookingProtocolViewState extends State<_CookingProtocolView> {
  late RecipeLanguage _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CookingViewModel>();
    final currentStep = vm.currentStep;
    final hasPouch = currentStep.masalaPouchNumber != null;

    final minutes = vm.secondsRemaining ~/ 60;
    final seconds = vm.secondsRemaining % 60;
    final timeFormatted = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Check if finished
    if (vm.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CookingRewardDialog(recipe: vm.recipe),
        );
      });
    }

    final flameLabel = currentStep.getFlameLevelLabel(_currentLanguage);
    final proTip = currentStep.getProTip(_currentLanguage);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'PROTOCOL: ${vm.recipe.getTitle(_currentLanguage).toUpperCase()}',
          style: AppTypography.headlineSm.copyWith(
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Download Recipe PDF Card',
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 20),
            onPressed: () {
              InvoiceDownloadHelper.downloadRecipePdf(
                context: context,
                recipe: vm.recipe,
                ingredients: vm.recipe.ingredients,
                isDark: isDark,
              );
            },
          ),
          PouchBadge(pouchNumber: vm.recipe.masalaPouchNumber),
          const SizedBox(width: 16),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.gridLine : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            if (vm.currentStepIndex > 0) ...[
              Expanded(
                child: BrutalistButton(
                  text: _currentLanguage == RecipeLanguage.gujarati
                      ? 'પાછળ'
                      : _currentLanguage == RecipeLanguage.hindi
                          ? 'पिछला'
                          : 'Previous Step',
                  variant: BrutalistButtonVariant.outline,
                  onPressed: vm.previousStep,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: BrutalistButton(
                text: vm.currentStepIndex == vm.steps.length - 1
                    ? (_currentLanguage == RecipeLanguage.gujarati
                        ? 'રસોઈ પૂર્ણ કરો'
                        : _currentLanguage == RecipeLanguage.hindi
                            ? 'कुकिंग पूरी करें'
                            : 'Complete Recipe Protocol')
                    : (_currentLanguage == RecipeLanguage.gujarati
                        ? 'આગળનું સ્ટેપ (${vm.currentStepIndex + 2}/${vm.steps.length})'
                        : _currentLanguage == RecipeLanguage.hindi
                            ? 'अगला चरण (${vm.currentStepIndex + 2}/${vm.steps.length})'
                            : 'Next Step (${vm.currentStepIndex + 2}/${vm.steps.length})'),
                icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                onPressed: vm.nextStep,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Multilingual switcher strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      _currentLanguage == RecipeLanguage.gujarati
                          ? 'ભાષા:'
                          : _currentLanguage == RecipeLanguage.hindi
                              ? 'भाषा:'
                              : 'LANG:',
                      style: AppTypography.metadata.copyWith(
                        fontSize: 11,
                        color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MiniLangPill(
                      label: '🇬🇧 EN',
                      isSelected: _currentLanguage == RecipeLanguage.english,
                      onTap: () => setState(() => _currentLanguage = RecipeLanguage.english),
                    ),
                    const SizedBox(width: 6),
                    _MiniLangPill(
                      label: '🇮🇳 ગુજરાતી',
                      isSelected: _currentLanguage == RecipeLanguage.gujarati,
                      onTap: () => setState(() => _currentLanguage = RecipeLanguage.gujarati),
                    ),
                    const SizedBox(width: 6),
                    _MiniLangPill(
                      label: '🇮🇳 हिन्दी',
                      isSelected: _currentLanguage == RecipeLanguage.hindi,
                      onTap: () => setState(() => _currentLanguage = RecipeLanguage.hindi),
                    ),
                  ],
                ),
              ),
            ),

            // Segmented Progress Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentLanguage == RecipeLanguage.gujarati
                            ? 'સ્ટેપ ${vm.currentStepIndex + 1} / ${vm.steps.length}'
                            : _currentLanguage == RecipeLanguage.hindi
                                ? 'चरण ${vm.currentStepIndex + 1} / ${vm.steps.length}'
                                : 'STEP ${vm.currentStepIndex + 1} OF ${vm.steps.length}',
                        style: AppTypography.metadata.copyWith(color: AppColors.primary),
                      ),
                      Text(
                        '${(vm.stepProgress * 100).toInt()}% COMPLETE',
                        style: AppTypography.numericData.copyWith(
                          fontSize: 12,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(vm.steps.length, (idx) {
                      final isDone = idx < vm.currentStepIndex;
                      final isCurrent = idx == vm.currentStepIndex;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.primary
                                : isCurrent
                                    ? AppColors.secondaryOrange
                                    : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightBorder),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.gridLine : AppColors.lightBorder),

            // Main Step Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Masala Pouch Invocations
                    if (hasPouch) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white38, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2, color: Colors.white, size: 32),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentLanguage == RecipeLanguage.gujarati
                                        ? 'મસાલા પાઉચ ઉમેરો'
                                        : _currentLanguage == RecipeLanguage.hindi
                                            ? 'मसाला पाउच मिलाएं'
                                            : 'ACTION REQUIRED: TEAR POUCH',
                                    style: AppTypography.metadata.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _currentLanguage == RecipeLanguage.gujarati
                                        ? 'જીરોલા મસાલા પાઉચ ${currentStep.masalaPouchNumber!} ઉમેરો'
                                        : _currentLanguage == RecipeLanguage.hindi
                                            ? 'जीरोला मसाला पाउच ${currentStep.masalaPouchNumber!} डालें'
                                            : 'Add Masala Pouch ${currentStep.masalaPouchNumber!} (${vm.recipe.pouchName})',
                                    style: AppTypography.headlineSm.copyWith(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Step Number, Flame badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'STEP 0${currentStep.stepNumber}',
                          style: AppTypography.displayXl.copyWith(
                            fontSize: 22,
                            color: AppColors.sproutGreen,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                              border: Border.all(color: AppColors.secondaryOrange),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              flameLabel,
                              style: AppTypography.metadata.copyWith(
                                color: AppColors.secondaryOrange,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentStep.getTitle(_currentLanguage),
                      style: AppTypography.headlineLg.copyWith(
                        fontSize: 20,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Instruction (large counter-friendly font)
                    BrutalistCard(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                      borderColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
                      child: Text(
                        currentStep.getInstruction(_currentLanguage),
                        style: AppTypography.bodyLg.copyWith(
                          fontSize: 18,
                          height: 1.6,
                          color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),

                    // Pro Chef Secret Tip Box
                    if (proTip != null && proTip.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(color: AppColors.secondaryOrange, width: 4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentLanguage == RecipeLanguage.gujarati
                                        ? 'પ્રો શેફ સિક્રેટ (સ્ક્રેચથી એડવાન્સ્ડ)'
                                        : _currentLanguage == RecipeLanguage.hindi
                                            ? 'प्रो शेफ सीक्रेट (स्क्रैच से एडवांस्ड)'
                                            : 'PRO CHEF SECRET (SCRATCH TO ADVANCED)',
                                    style: AppTypography.metadata.copyWith(
                                      color: AppColors.secondaryOrange,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    proTip,
                                    style: AppTypography.bodySm.copyWith(
                                      fontSize: 13,
                                      color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Step Timer
                    BrutalistCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                      borderColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: vm.isTimerRunning ? AppColors.secondaryOrange : AppColors.outline,
                                  size: 26,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _currentLanguage == RecipeLanguage.gujarati
                                            ? 'સ્ટેપ સમય'
                                            : _currentLanguage == RecipeLanguage.hindi
                                                ? 'चरण समय'
                                                : 'STEP DURATION',
                                        style: AppTypography.metadata.copyWith(
                                          color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        timeFormatted,
                                        style: AppTypography.displayXl.copyWith(
                                          fontSize: 24,
                                          color: vm.isTimerRunning
                                              ? AppColors.secondaryOrange
                                              : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          BrutalistButton(
                            text: vm.isTimerRunning
                                ? (_currentLanguage == RecipeLanguage.gujarati
                                    ? 'વિરામ'
                                    : _currentLanguage == RecipeLanguage.hindi
                                        ? 'रोकें'
                                        : 'PAUSE')
                                : (_currentLanguage == RecipeLanguage.gujarati
                                    ? 'ટાઈમર શરૂ'
                                    : _currentLanguage == RecipeLanguage.hindi
                                        ? 'टाइमर शुरू'
                                        : 'START TIMER'),
                            variant: vm.isTimerRunning ? BrutalistButtonVariant.secondary : BrutalistButtonVariant.primary,
                            icon: Icon(
                              vm.isTimerRunning ? Icons.pause : Icons.play_arrow,
                              size: 16,
                              color: vm.isTimerRunning ? AppColors.surfaceBlack : Colors.white,
                            ),
                            onPressed: vm.toggleTimer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniLangPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MiniLangPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceContainerHigh : Colors.white),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.gridLine : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppColors.surfaceBlack : Colors.black87)
                : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }
}
