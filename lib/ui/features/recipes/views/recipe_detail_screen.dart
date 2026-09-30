import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/widgets/pouch_badge.dart';
import '../../../../data/models/ingredient_model.dart';
import '../../../../data/models/recipe_model.dart';
import '../../../../data/services/recipe_localization_service.dart';
import '../../../../core/utils/invoice_download_helper.dart';
import '../../cooking/views/cooking_protocol_screen.dart';
import '../../shopping_list/view_models/shopping_list_view_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  RecipeLanguage _selectedLanguage = RecipeLanguage.english;
  late RecipeModel _localizedRecipe;
  late List<IngredientModel> _ingredients;

  @override
  void initState() {
    super.initState();
    _localizedRecipe = RecipeLocalizationService.localize(widget.recipe, _selectedLanguage);
    _ingredients = List.from(_localizedRecipe.ingredients);
  }

  void _changeLanguage(RecipeLanguage lang) {
    if (_selectedLanguage == lang) return;
    setState(() {
      _selectedLanguage = lang;
      final localized = RecipeLocalizationService.localize(widget.recipe, lang);
      final updatedList = <IngredientModel>[];
      for (int i = 0; i < localized.ingredients.length; i++) {
        final existingChecked = i < _ingredients.length ? _ingredients[i].isAvailableInKitchen : false;
        updatedList.add(localized.ingredients[i].copyWith(isAvailableInKitchen: existingChecked));
      }
      _ingredients = updatedList;
      _localizedRecipe = localized.copyWith(ingredients: updatedList);
    });
  }

  void _toggleKitchenAvailable(int index) {
    setState(() {
      final item = _ingredients[index];
      _ingredients[index] = item.copyWith(
        isAvailableInKitchen: !item.isAvailableInKitchen,
      );
    });
  }

  String _getSectionTitle(String en, String gu, String hi) {
    switch (_selectedLanguage) {
      case RecipeLanguage.gujarati:
        return gu;
      case RecipeLanguage.hindi:
        return hi;
      case RecipeLanguage.english:
        return en;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _localizedRecipe;
    final shoppingVm = context.read<ShoppingListViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final missingCount = _ingredients.where((i) => !i.isAvailableInKitchen).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            actions: [
              IconButton(
                tooltip: 'Download Recipe PDF',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 18),
                ),
                onPressed: () {
                  InvoiceDownloadHelper.downloadRecipePdf(
                    context: context,
                    recipe: _localizedRecipe,
                    ingredients: _ingredients,
                    isDark: isDark,
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          isDark ? AppColors.surfaceBlack : Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PouchBadge(
                          pouchNumber: recipe.masalaPouchNumber,
                          pouchName: recipe.pouchName,
                          isLarge: true,
                        ),
                        const SizedBox(height: 8),
                        Text(recipe.title, style: AppTypography.displayXl.copyWith(fontSize: 24)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Selector Bar (English / ગુજરાતી / हिन्दी)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceContainerHigh : Colors.white,
                      border: Border.all(
                        color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _LanguageButton(
                          label: '🇬🇧 English',
                          isSelected: _selectedLanguage == RecipeLanguage.english,
                          onTap: () => _changeLanguage(RecipeLanguage.english),
                        ),
                        const SizedBox(width: 4),
                        _LanguageButton(
                          label: '🇮🇳 ગુજરાતી',
                          isSelected: _selectedLanguage == RecipeLanguage.gujarati,
                          onTap: () => _changeLanguage(RecipeLanguage.gujarati),
                        ),
                        const SizedBox(width: 4),
                        _LanguageButton(
                          label: '🇮🇳 हिन्दी',
                          isSelected: _selectedLanguage == RecipeLanguage.hindi,
                          onTap: () => _changeLanguage(RecipeLanguage.hindi),
                        ),
                      ],
                    ),
                  ),

                  // Meta Stats Bar
                  BrutalistCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MetaStat(
                            label: _getSectionTitle('PREP', 'તૈયારી', 'तैयारी'),
                            value: '${recipe.prepTimeMinutes}m',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                        ),
                        Expanded(
                          child: _MetaStat(
                            label: _getSectionTitle('COOK', 'પકવવું', 'पकाना'),
                            value: '${recipe.cookTimeMinutes}m',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                        ),
                        Expanded(
                          child: _MetaStat(
                            label: _getSectionTitle('SERVINGS', 'સર્વિંગ્સ', 'सर्विंग्स'),
                            value: '${recipe.servings}',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                        ),
                        Expanded(
                          child: _MetaStat(
                            label: _getSectionTitle('CUISINE', 'વાનગી', 'व्यंजन'),
                            value: recipe.cuisine,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Asafoetida / Hing Kit Spec
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceContainer : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: recipe.isHingFree
                            ? AppColors.sproutGreen
                            : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          recipe.isHingFree ? Icons.check_circle_outline : Icons.grain,
                          size: 16,
                          color: recipe.isHingFree ? AppColors.sproutGreen : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recipe.isHingFree
                                ? _getSectionTitle(
                                    '100% Without Asafoetida (Hing-Free Satvik Kit)',
                                    '૧૦૦% હીંગ મુક્ત સાત્વિક મસાલા કિટ',
                                    '१००% हींग मुक्त सात्विक मसाला किट',
                                  )
                                : _getSectionTitle(
                                    'With Asafoetida (Traditional Hing Masala Kit)',
                                    'હીંગ સાથે પરંપરાગત મસાલા કિટ',
                                    'हींग युक्त पारंपरिक मसाला किट',
                                  ),
                            style: AppTypography.metadata.copyWith(
                              color: recipe.isHingFree
                                  ? AppColors.sproutGreen
                                  : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(recipe.description, style: AppTypography.bodyMd),
                  const SizedBox(height: 24),

                  // Ingredients Section with Pantry Checkboxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getSectionTitle(
                                'INGREDIENTS CHECKLIST',
                                'સામગ્રી યાદી (Ingredients)',
                                'सामग्री सूची (Ingredients)',
                              ),
                              style: AppTypography.headlineSm.copyWith(fontSize: 16),
                            ),
                            Text(
                              _getSectionTitle(
                                'Mark items you already have in your kitchen',
                                'તમારા રસોડામાં ઉપલબ્ધ સામગ્રી પર નિશાની કરો',
                                'जो सामग्री आपकी रसोई में है उस पर टिक करें',
                              ),
                              style: AppTypography.bodySm,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedLanguage == RecipeLanguage.gujarati
                            ? '$missingCount ખૂટે છે'
                            : _selectedLanguage == RecipeLanguage.hindi
                                ? '$missingCount बाकी है'
                                : '$missingCount Missing',
                        style: AppTypography.numericData.copyWith(
                          color: missingCount > 0 ? AppColors.secondaryOrange : AppColors.sproutGreen,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ingredients List
                  ...List.generate(_ingredients.length, (index) {
                    final ing = _ingredients[index];
                    final displayName = ing.getName(_selectedLanguage);
                    final displayUnit = ing.getUnit(_selectedLanguage);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: ing.isAvailableInKitchen
                            ? (isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm)
                            : (isDark ? AppColors.surfaceContainer : Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: ing.isAvailableInKitchen
                                ? AppColors.sproutGreen
                                : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          dense: true,
                          leading: Checkbox(
                            value: ing.isAvailableInKitchen,
                            onChanged: (_) => _toggleKitchenAvailable(index),
                          ),
                          title: Text(
                            displayName,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: ing.isAvailableInKitchen ? TextDecoration.lineThrough : null,
                              color: ing.isAvailableInKitchen
                                  ? (isDark ? AppColors.onSurfaceVariant : AppColors.lightTextTertiary)
                                  : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                            ),
                          ),
                          subtitle: Text(
                            '${ing.quantity.toInt()} $displayUnit (Market: ${ing.marketPackSize.toInt()}${ing.marketPackUnit})',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 12,
                              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                            ),
                          ),
                          trailing: ing.name.contains('Pouch')
                              ? PouchBadge(pouchNumber: recipe.masalaPouchNumber)
                              : null,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Action to add missing items to cart
                  if (missingCount > 0)
                    BrutalistButton(
                      text: _selectedLanguage == RecipeLanguage.gujarati
                          ? '$missingCount ખૂટતી સામગ્રી શોપિંગ લિસ્ટમાં ઉમેરો'
                          : _selectedLanguage == RecipeLanguage.hindi
                              ? '$missingCount बची हुई सामग्री शॉपिंग लिस्ट में जोड़ें'
                              : 'Add $missingCount Missing Ingredients To Shopping List',
                      variant: BrutalistButtonVariant.secondary,
                      isFullWidth: true,
                      icon: const Icon(Icons.add_shopping_cart, size: 18, color: AppColors.surfaceBlack),
                      onPressed: () {
                        for (final ing in _ingredients.where((i) => !i.isAvailableInKitchen)) {
                          shoppingVm.addMissingIngredient(ing);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _selectedLanguage == RecipeLanguage.gujarati
                                  ? '$missingCount સામગ્રી શોપિંગ કાર્ટમાં ઉમેરાઈ ગઈ'
                                  : _selectedLanguage == RecipeLanguage.hindi
                                      ? '$missingCount सामग्री शॉपिंग कार्ट में जोड़ी गई'
                                      : 'Added $missingCount items to your Smart Shopping Cart',
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 28),

                  // Cooking Protocol Steps Preview
                  Text(
                    _getSectionTitle(
                      'COOKING PROTOCOL & POUCH TIMELINE',
                      'રસોઈ માર્ગદર્શિકા અને પાઉચ ટાઈમલાઈન',
                      'कुक-गाइड और पाउच टाइमलाइन',
                    ),
                    style: AppTypography.headlineSm.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSectionTitle(
                      'Follow step-by-step with Jeerola Masala Kit',
                      'જીરોલા મસાલા કિટ સાથે સ્ટેપ-બાય-સ્ટેપ બનાવો (સ્ક્રેચથી એડવાન્સ્ડ)',
                      'जीरोला मसाला किट के साथ स्टेप-बाई-स्टेप पकाएं (स्क्रैच से एडवांस्ड)',
                    ),
                    style: AppTypography.bodySm,
                  ),
                  const SizedBox(height: 14),

                  ...recipe.steps.map((step) {
                    final hasPouch = step.masalaPouchNumber != null;
                    final flameLabel = step.getFlameLevelLabel(_selectedLanguage);
                    final proTip = step.getProTip(_selectedLanguage);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: BrutalistCard(
                        borderColor: hasPouch ? AppColors.terracotta : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        borderWidth: hasPouch ? 1.5 : 1.0,
                        backgroundColor: isDark ? AppColors.surfaceContainerHigh : Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: hasPouch
                                    ? AppColors.terracotta
                                    : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '${step.stepNumber}',
                                  style: AppTypography.labelPouch.copyWith(
                                    fontSize: 13,
                                    color: hasPouch ? Colors.white : (isDark ? Colors.white : AppColors.lightTextPrimary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          step.getTitle(_selectedLanguage),
                                          style: AppTypography.headlineSm.copyWith(
                                            fontSize: 14,
                                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                      ),
                                      if (hasPouch) ...[
                                        const SizedBox(width: 8),
                                        PouchBadge(pouchNumber: step.masalaPouchNumber!),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Flame badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.secondaryOrange.withValues(alpha: 0.5)),
                                    ),
                                    child: Text(
                                      flameLabel,
                                      style: AppTypography.metadata.copyWith(
                                        color: AppColors.secondaryOrange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    step.getInstruction(_selectedLanguage),
                                    style: AppTypography.bodySm.copyWith(height: 1.45),
                                  ),
                                  if (proTip != null && proTip.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.terracotta.withValues(alpha: 0.12),
                                        border: const Border(
                                          left: BorderSide(color: AppColors.terracotta, width: 3),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('💡 ', style: TextStyle(fontSize: 13)),
                                          Expanded(
                                            child: Text(
                                              proTip,
                                              style: AppTypography.bodySm.copyWith(
                                                fontSize: 12,
                                                color: AppColors.primary,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Launch Cooking Protocol CTA
                  BrutalistButton(
                    text: _selectedLanguage == RecipeLanguage.gujarati
                        ? 'સ્ટેપ-બાય-સ્ટેપ રસોઈ શરૂ કરો'
                        : _selectedLanguage == RecipeLanguage.hindi
                            ? 'स्टेप-बाई-स्टेप कुकिंग शुरू करें'
                            : 'Start Step-by-Step Cooking Protocol',
                    isFullWidth: true,
                    icon: const Icon(Icons.play_arrow, size: 20, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CookingProtocolScreen(
                            recipe: _localizedRecipe,
                            initialLanguage: _selectedLanguage,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Download Recipe PDF Action
                  BrutalistButton(
                    text: _selectedLanguage == RecipeLanguage.gujarati
                        ? 'રેસિપી પ્રોટોકોલ ડાઉનલોડ કરો (PDF)'
                        : _selectedLanguage == RecipeLanguage.hindi
                            ? 'रेसिपी प्रोटोकॉल डाउनलोड करें (PDF)'
                            : 'Download Recipe Card (PDF)',
                    variant: BrutalistButtonVariant.outline,
                    isFullWidth: true,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.primary),
                    onPressed: () {
                      InvoiceDownloadHelper.downloadRecipePdf(
                        context: context,
                        recipe: _localizedRecipe,
                        ingredients: _ingredients,
                        isDark: isDark,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: AppColors.primaryDark, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaStat extends StatefulWidget {
  final String label;
  final String value;

  const _MetaStat({required this.label, required this.value});

  @override
  State<_MetaStat> createState() => _MetaStatState();
}

class _MetaStatState extends State<_MetaStat> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.label,
          style: AppTypography.metadata,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          widget.value,
          style: AppTypography.numericData.copyWith(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
