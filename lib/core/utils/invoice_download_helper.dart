import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import '../../data/models/ingredient_model.dart';
import '../../data/models/recipe_model.dart';
import 'app_toast.dart';

/// Helper to handle invoice & recipe PDF generation, storage permissions, and download/sharing.
class InvoiceDownloadHelper {
  InvoiceDownloadHelper._();

  /// Requests necessary storage permissions if applicable.
  /// On modern Android (API 30+) and iOS, sandboxed storage and Printing.sharePdf
  /// do not require WRITE_EXTERNAL_STORAGE.
  static Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (status.isGranted || status.isLimited) return true;

        final result = await Permission.storage.request();
        return result.isGranted || result.isLimited;
      }
    } catch (e) {
      debugPrint('Storage permission check skipped: $e');
    }

    return true;
  }

  /// Generates a branded Jeerola invoice PDF and initiates download/share.
  static Future<void> downloadInvoice({
    required BuildContext context,
    required String orderId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String storeName = 'Jeerola Dark Store & Cloud Kitchen',
    String deliveryAddress = 'Flat 202, Yogibhuvan Appartment, Shahpur, Amdavad',
    bool isDark = true,
  }) async {
    try {
      // 1. Check permissions gracefully without blocking PDF creation on modern Android
      try {
        await requestStoragePermission();
      } catch (_) {}

      AppToast.info('Generating PDF invoice for $orderId... ⏳', isDark: isDark);

      // 2. Build PDF Document
      final pdf = pw.Document();
      final now = DateTime.now();
      final formattedDate = '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'JEEROLA',
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.deepOrange,
                          ),
                        ),
                        pw.Text(
                          'Culinary OS & Fresh Dark Store',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'TAX INVOICE',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Order ID: $orderId', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.deepOrange),
                pw.SizedBox(height: 12),

                // Store & Delivery Details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Billed From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text(storeName, style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('GSTIN: 24AAAFJ1234F1Z8', style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Deliver To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text('Nehal Patel', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text(deliveryAddress, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),

                // Table of Items
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right)),
                      ],
                    ),
                    ...items.map((item) {
                      final name = item['name'] as String? ?? 'Kitchen Item';
                      final qty = item['qty'] as int? ?? 1;
                      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                      final amount = price * qty;
                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(name, style: const pw.TextStyle(fontSize: 9))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$qty', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Rs. ${price.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Rs. ${amount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: Rs. ${(totalAmount * 0.95).toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('GST (5%): Rs. ${(totalAmount * 0.05).toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Divider(color: PdfColors.grey400),
                        pw.Text(
                          'Total Paid: Rs. ${totalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),

                // Footer Note
                pw.Divider(color: PdfColors.grey300),
                pw.Center(
                  child: pw.Text(
                    'Thank you for cooking with Jeerola! For any order queries, contact support@jeerola.com',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // 3. Save or Share the PDF
      final pdfBytes = await pdf.save();

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/Invoice_$orderId.pdf');
        await file.writeAsBytes(pdfBytes);

        // Open native share/print dialog
        await Printing.sharePdf(bytes: pdfBytes, filename: 'Invoice_$orderId.pdf');
        AppToast.success('Invoice $orderId downloaded & ready! 📄', isDark: isDark);
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'Invoice_$orderId',
        );
        AppToast.success('Invoice $orderId generated! 📄', isDark: isDark);
      }
    } catch (e) {
      debugPrint('Error downloading invoice: $e');
      AppToast.error('Could not download invoice: $e', isDark: isDark);
    }
  }

  /// Generates a branded Jeerola Recipe Protocol PDF card and initiates download/share.
  static Future<void> downloadRecipePdf({
    required BuildContext context,
    required RecipeModel recipe,
    List<IngredientModel>? ingredients,
    bool isDark = true,
  }) async {
    try {
      try {
        await requestStoragePermission();
      } catch (_) {}

      final sanitizedTitle = _safeAscii(recipe.getTitle(RecipeLanguage.english));
      AppToast.info('Preparing PDF Recipe Card for $sanitizedTitle... ⏳', isDark: isDark);

      final pdf = pw.Document();
      final ingList = ingredients ?? recipe.ingredients;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context ctx) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.deepOrange, width: 2)),
              ),
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'JEEROLA CULINARY ACADEMY',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.deepOrange,
                        ),
                      ),
                      pw.Text(
                        'Smart Kitchen Recipe & Masala Pouch Protocol',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: PdfColors.deepOrange),
                    ),
                    child: pw.Text(
                      'KIT: ${_safeAscii(recipe.masalaPouchNumber)} (${_safeAscii(recipe.pouchName)})',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange),
                    ),
                  ),
                ],
              ),
            );
          },
          footer: (pw.Context ctx) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 12),
              padding: const pw.EdgeInsets.only(top: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Jeerola Culinary OS - 100% Authentic Indian Spice Blends',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context ctx) {
            return [
              // Recipe Title & Description
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          _safeAscii(recipe.getTitle(RecipeLanguage.english)),
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _safeAscii(recipe.description),
                          style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // Metrics Banner
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPdfStatItem('PREP TIME', '${recipe.prepTimeMinutes}m'),
                    _buildPdfStatItem('COOK TIME', '${recipe.cookTimeMinutes}m'),
                    _buildPdfStatItem('TOTAL TIME', '${recipe.totalTimeMinutes}m'),
                    _buildPdfStatItem('SERVINGS', '${recipe.servings} Servings'),
                    _buildPdfStatItem('CUISINE', _safeAscii(recipe.cuisine)),
                    _buildPdfStatItem('DIET', recipe.isVeg ? 'Vegetarian' : 'Non-Veg'),
                    _buildPdfStatItem('HING STATUS', recipe.isHingFree ? 'Hing-Free Satvik' : 'Traditional Hing'),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Ingredients Section
              pw.Text(
                'REQUIRED INGREDIENTS (${ingList.length})',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Kitchen Check', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Ingredient', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Required Qty', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Market Pack Size', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  ...ingList.map((ing) {
                    final isPouch = ing.name.contains('Pouch') || ing.name.contains('Masala');
                    return pw.TableRow(
                      decoration: isPouch ? const pw.BoxDecoration(color: PdfColors.amber50) : null,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            ing.isAvailableInKitchen ? '[x] In Kitchen' : '[ ] Needed',
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: ing.isAvailableInKitchen ? PdfColors.green800 : PdfColors.red800,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            _safeAscii(ing.getName(RecipeLanguage.english)) + (isPouch ? ' (JEEROLA POUCH)' : ''),
                            style: pw.TextStyle(fontSize: 8.5, fontWeight: isPouch ? pw.FontWeight.bold : pw.FontWeight.normal),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '${ing.quantity.toInt()} ${_safeAscii(ing.getUnit(RecipeLanguage.english))}',
                            style: const pw.TextStyle(fontSize: 8.5),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '${ing.marketPackSize.toInt()}${_safeAscii(ing.marketPackUnit)}',
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),

              // Step-by-Step Cooking Protocol
              pw.Text(
                'COOKING PROTOCOL & POUCH TIMELINE (${recipe.steps.length} STEPS)',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange),
              ),
              pw.SizedBox(height: 6),
              ...recipe.steps.map((step) {
                final hasPouch = step.masalaPouchNumber != null;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: hasPouch ? PdfColors.orange50 : PdfColors.white,
                    border: pw.Border.all(
                      color: hasPouch ? PdfColors.deepOrange : PdfColors.grey300,
                      width: hasPouch ? 1.2 : 0.8,
                    ),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Step ${step.stepNumber}: ${_safeAscii(step.getTitle(RecipeLanguage.english))}',
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              color: hasPouch ? PdfColors.deepOrange : PdfColors.black,
                            ),
                          ),
                          pw.Row(
                            children: [
                              if (step.flameLevel != null && step.flameLevel!.isNotEmpty) ...[
                                pw.Text(
                                  'Flame: ${_safeAscii(step.getFlameLevelLabel(RecipeLanguage.english))}  |  ',
                                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                                ),
                              ],
                              pw.Text(
                                '${step.durationMinutes} mins',
                                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (hasPouch) ...[
                        pw.SizedBox(height: 3),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.deepOrange,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                          ),
                          child: pw.Text(
                            'ACTION: TEAR & ADD MASALA POUCH ${step.masalaPouchNumber!} (${_safeAscii(recipe.pouchName)})',
                            style: pw.TextStyle(fontSize: 7.5, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                      pw.SizedBox(height: 4),
                      pw.Text(
                        _safeAscii(step.getInstruction(RecipeLanguage.english)),
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey900),
                      ),
                      if (step.proTip != null && step.proTip!.isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Chef Pro Tip: ${_safeAscii(step.getProTip(RecipeLanguage.english))}',
                          style: pw.TextStyle(fontSize: 7.5, color: PdfColors.green900, fontStyle: pw.FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ];
          },
        ),
      );

      // Save or Share the PDF
      final pdfBytes = await pdf.save();
      final safeFileName = 'Recipe_${recipe.id}_${recipe.masalaPouchNumber}.pdf';

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$safeFileName');
        await file.writeAsBytes(pdfBytes);

        // Native share / save / print dialog
        await Printing.sharePdf(bytes: pdfBytes, filename: safeFileName);
        AppToast.success('Recipe PDF card downloaded & ready! 📜', isDark: isDark);
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'Recipe_${recipe.id}',
        );
        AppToast.success('Recipe PDF generated! 📜', isDark: isDark);
      }
    } catch (e) {
      debugPrint('Error generating recipe PDF: $e');
      AppToast.error('Could not download recipe: $e', isDark: isDark);
    }
  }

  static pw.Widget _buildPdfStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange),
        ),
      ],
    );
  }

  /// Sanitizes text to Latin-1/ASCII characters safe for PDF standard Helvetica font.
  static String _safeAscii(String? text) {
    if (text == null || text.isEmpty) return '';
    final sanitized = text
        .replaceAll('₹', 'Rs. ')
        .replaceAll('•', '-')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('⭐', '* ')
        .replaceAll('✔', '[OK]')
        .replaceAll('✓', '[OK]')
        .replaceAll('❌', '[X]');

    final buffer = StringBuffer();
    for (final rune in sanitized.runes) {
      if (rune <= 255) {
        buffer.writeCharCode(rune);
      } else {
        buffer.write(' ');
      }
    }
    return buffer.toString().trim();
  }
}
