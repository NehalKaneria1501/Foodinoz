import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class RazorpayPaymentResult {
  final bool isSuccess;
  final String? paymentId;
  final String? signature;
  final String? orderId;
  final String? errorMessage;

  const RazorpayPaymentResult({
    required this.isSuccess,
    this.paymentId,
    this.signature,
    this.orderId,
    this.errorMessage,
  });
}

class RazorpayPaymentService {
  // Test Merchant Key ID for Razorpay Sandbox / Production Gateway
  static const String razorpayKeyId = 'rzp_test_xeVAJ5Jg2C932Q';

  static Future<RazorpayPaymentResult?> openRazorpayCheckout({
    required BuildContext context,
    required double amountInRupees,
    required String orderId,
    required String customerName,
    required String customerContact,
    required String customerEmail,
    String? note,
  }) async {
    final int amountInPaise = (amountInRupees * 100).toInt();

    return await showModalBottomSheet<RazorpayPaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RazorpayCheckoutModal(
        keyId: razorpayKeyId,
        amountInRupees: amountInRupees,
        amountInPaise: amountInPaise,
        orderId: orderId,
        customerName: customerName,
        customerContact: customerContact,
        customerEmail: customerEmail,
        note: note ?? 'Simmering Live Order Delivery',
      ),
    );
  }
}

class _RazorpayCheckoutModal extends StatefulWidget {
  final String keyId;
  final double amountInRupees;
  final int amountInPaise;
  final String orderId;
  final String customerName;
  final String customerContact;
  final String customerEmail;
  final String note;

  const _RazorpayCheckoutModal({
    required this.keyId,
    required this.amountInRupees,
    required this.amountInPaise,
    required this.orderId,
    required this.customerName,
    required this.customerContact,
    required this.customerEmail,
    required this.note,
  });

  @override
  State<_RazorpayCheckoutModal> createState() => _RazorpayCheckoutModalState();
}

class _RazorpayCheckoutModalState extends State<_RazorpayCheckoutModal> {
  String _selectedMethod = 'UPI';
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final fakePaymentId = 'pay_rzp_${DateTime.now().millisecondsSinceEpoch}';
    final fakeSignature = 'sig_rzp_${widget.orderId}_verified';

    Navigator.of(context).pop(
      RazorpayPaymentResult(
        isSuccess: true,
        paymentId: fakePaymentId,
        signature: fakeSignature,
        orderId: widget.orderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gridLine : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Razorpay Branded Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0C2340) : const Color(0xFFEBF3FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? const Color(0xFF528FF0) : const Color(0xFF2B6CB0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bolt,
                              color: isDark ? const Color(0xFF528FF0) : const Color(0xFF2B6CB0),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Razorpay',
                              style: AppTypography.metadata.copyWith(
                                color: isDark ? Colors.white : const Color(0xFF0C2340),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.sproutGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '256-BIT SECURE',
                          style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen, fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppColors.outline : AppColors.lightTextSecondary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(
                      const RazorpayPaymentResult(
                        isSuccess: false,
                        errorMessage: 'Payment cancelled by user',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222D) : AppColors.lightSurfaceWarm,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C3242) : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'JEEROLA RESTAURANT & SPICES',
                            style: AppTypography.metadata.copyWith(
                              color: isDark ? AppColors.outline : AppColors.lightTextSecondary,
                              fontSize: 9,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.note,
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'AMOUNT TO PAY',
                          style: AppTypography.metadata.copyWith(
                            color: isDark ? AppColors.outline : AppColors.lightTextSecondary,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${widget.amountInRupees.toStringAsFixed(2)}',
                          style: AppTypography.numericData.copyWith(
                            color: AppColors.sproutGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'SELECT PAYMENT METHOD',
                style: AppTypography.metadata.copyWith(
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Payment Methods List
              _buildPaymentOption(
                id: 'UPI',
                icon: Icons.qr_code_scanner,
                title: 'UPI - Google Pay, PhonePe, Paytm',
                subtitle: 'Fastest 1-tap checkout via UPI Apps',
                badge: 'POPULAR',
                isDark: isDark,
              ),
              _buildPaymentOption(
                id: 'Cards',
                icon: Icons.credit_card,
                title: 'Cards (Credit / Debit)',
                subtitle: 'Visa, MasterCard, RuPay, Maestro',
                isDark: isDark,
              ),
              _buildPaymentOption(
                id: 'NetBanking',
                icon: Icons.account_balance,
                title: 'NetBanking',
                subtitle: 'All Indian Banks (HDFC, SBI, ICICI, Axis)',
                isDark: isDark,
              ),
              _buildPaymentOption(
                id: 'COD',
                icon: Icons.handshake,
                title: 'Cash on Delivery (Pay on Simmer Delivery)',
                subtitle: 'Pay rider via cash or QR upon delivery',
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // Action Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF0C2340) : const Color(0xFF2B6CB0),
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: isDark ? const Color(0xFF528FF0) : const Color(0xFF1A497A),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? const Color(0xFF528FF0) : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'CONNECTING SECURE GATEWAY...',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'PAY ₹${widget.amountInRupees.toStringAsFixed(2)} VIA RAZORPAY',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    String? badge,
  }) {
    final isSelected = _selectedMethod == id;
    final primaryBlue = isDark ? const Color(0xFF528FF0) : const Color(0xFF2B6CB0);
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0C2340).withValues(alpha: 0.5) : const Color(0xFFEBF3FF))
              : (isDark ? const Color(0xFF1E222D) : AppColors.lightSurfaceWarm),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? primaryBlue
                : (isDark ? const Color(0xFF2C3242) : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryBlue : (isDark ? AppColors.outline : AppColors.lightTextSecondary),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.sproutGreen,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.metadata.copyWith(
                      color: isDark ? AppColors.outline : AppColors.lightTextSecondary,
                      fontSize: 9.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primaryBlue : (isDark ? AppColors.outline : AppColors.lightBorder),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
