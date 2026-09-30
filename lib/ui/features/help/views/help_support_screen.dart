import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/utils/invoice_download_helper.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Delivery',
      'question': 'How fast is Jeerola Simmering Delivery?',
      'answer': 'Our hyperlocal dark stores dispatch fresh spices, vegetables, and prep ingredients within 8 to 15 minutes across major city zones.',
    },
    {
      'category': 'Spices',
      'question': 'How are Jain and Swaminarayan masalas prepared?',
      'answer': 'All Jain and Swaminarayan spice blends are prepared in strictly dedicated facilities without root vegetables, garlic, or onion, following traditional purity standards.',
    },
    {
      'category': 'Refunds',
      'question': 'How do I claim a refund for a damaged or missing item?',
      'answer': 'Navigate to your Past Orders, select "Report Issue", upload a quick photo, and eligible refunds are credited to your original payment source or J-Coins wallet within 10 minutes.',
    },
    {
      'category': 'J-Coins',
      'question': 'How can I earn and use J-Coins?',
      'answer': 'Earn J-Coins by leaving verified recipe & spice reviews (up to 100 J-Coins per review). Use J-Coins during checkout for flat discounts on orders.',
    },
    {
      'category': 'Train Delivery',
      'question': 'Can I receive Jeerola orders on a running train?',
      'answer': 'Yes! Use "Order in Train" under your profile, enter your 10-digit PNR, coach, and berth. Our partner riders hand over sealed orders at scheduled station halts.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLiveChatModal() {
    final chatInputCtrl = TextEditingController();
    final List<Map<String, String>> messages = [
      {
        'sender': 'agent',
        'text': 'Namaste! Welcome to Jeerola Kitchen & Store Care. How can I assist your cooking or order today?',
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder, width: 1.5),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final screenHeight = MediaQuery.of(context).size.height;
            final sheetHeight = (screenHeight * 0.65).clamp(320.0, 520.0);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: sheetHeight,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder)),
                        color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.support_agent, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jeerola 24x7 Live Care',
                                  style: AppTypography.headlineSm.copyWith(
                                    fontSize: 14,
                                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.sproutGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text('Online • Avg reply: 30 secs', style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen, fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: isDark ? AppColors.outline : AppColors.lightTextTertiary),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isUser = msg['sender'] == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: const BoxConstraints(maxWidth: 280),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppColors.primary
                                    : (isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUser
                                      ? AppColors.primary
                                      : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                                ),
                              ),
                              child: Text(
                                msg['text'] ?? '',
                                style: AppTypography.bodySm.copyWith(
                                  color: isUser
                                      ? Colors.white
                                      : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder)),
                        color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: chatInputCtrl,
                              style: AppTypography.bodySm,
                              decoration: InputDecoration(
                                hintText: 'Type your message or order issue...',
                                hintStyle: AppTypography.bodySm.copyWith(color: AppColors.outline),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                filled: true,
                                fillColor: isDark ? AppColors.surfaceContainer : AppColors.lightSurfaceWarm,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 18),
                              onPressed: () {
                                final text = chatInputCtrl.text.trim();
                                if (text.isNotEmpty) {
                                  setModalState(() {
                                    messages.add({'sender': 'user', 'text': text});
                                    messages.add({
                                      'sender': 'agent',
                                      'text': 'We received your message: "$text". Our executive has received your ticket and is resolving it right away.',
                                    });
                                    chatInputCtrl.clear();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTicketStatusDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'YOUR ACTIVE TICKETS',
              style: AppTypography.headlineSm.copyWith(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.sproutGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TKT-99120',
                        style: AppTypography.metadata.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: AppColors.sproutGreen.withValues(alpha: 0.15),
                        child: Text('RESOLVED', style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen, fontSize: 9)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Issue: Quick dispatch delayed by 4 mins',
                    style: AppTypography.bodySm.copyWith(
                      color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Resolution: 50 J-Coins credited as courtesy apology.', style: AppTypography.metadata.copyWith(color: AppColors.primary, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CLOSE', style: AppTypography.metadata.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredFaqs = _faqs.where((f) {
      final matchesCat = _selectedCategory == 'All' || f['category'] == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          f['question'].toString().toLowerCase().contains(query) ||
          f['answer'].toString().toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'HELP & SUPPORT CENTER',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
            tooltip: 'My Tickets',
            onPressed: _showTicketStatusDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                  isDark ? AppColors.surfaceContainerHigh : Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headset_mic, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How can we help today?',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Instant resolution for spice orders, meal kits, train deliveries & refunds.',
                        style: AppTypography.bodySm.copyWith(
                          color: isDark ? AppColors.outline : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppTypography.bodyMd.copyWith(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search order issues, refunds, recipes...',
              hintStyle: TextStyle(
                color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.outline, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Action Grid (2x2)
          Text(
            '24/7 SUPPORT CHANNELS',
            style: AppTypography.metadata.copyWith(
              letterSpacing: 1.1,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSupportChannelCard(
                  icon: Icons.chat_bubble_outline,
                  color: AppColors.sproutGreen,
                  title: 'Live Chat',
                  subtitle: 'Avg wait: 30 secs',
                  onTap: _showLiveChatModal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSupportChannelCard(
                  icon: Icons.phone_in_talk_outlined,
                  color: AppColors.primary,
                  title: 'Call Support',
                  subtitle: '1800-JEEROLA (Toll-Free)',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connecting to Jeerola Priority Care: 1800-JEEROLA'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSupportChannelCard(
                  icon: Icons.mark_email_read_outlined,
                  color: AppColors.secondaryOrange,
                  title: 'Email Care',
                  subtitle: 'care@jeerola.com',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ticket created. Email dispatch initiated to care@jeerola.com'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSupportChannelCard(
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.terracotta,
                  title: 'Order Dispute',
                  subtitle: 'Damaged item or delay',
                  onTap: _showTicketStatusDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Last Order Assistance Card
          BrutalistCard(
            borderColor: isDark ? AppColors.primaryContainer : AppColors.primary.withValues(alpha: 0.3),
            backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LAST ORDER ASSISTANCE', style: AppTypography.metadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: AppColors.sproutGreen.withValues(alpha: 0.15),
                      child: Text('DELIVERED', style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen, fontSize: 9)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #ODR-893120 (Jeerola Dark Store)',
                  style: AppTypography.headlineSm.copyWith(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '3 items • ₹374.00 • Delivered in 9 mins',
                  style: AppTypography.bodySm.copyWith(
                    color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          InvoiceDownloadHelper.downloadInvoice(
                            context: context,
                            orderId: 'ODR-893120',
                            items: const [
                              {'name': 'Shahi Paneer Masala Blend (100g)', 'qty': 1, 'price': 149.0},
                              {'name': 'Organic Compounded Hing (50g)', 'qty': 1, 'price': 125.0},
                              {'name': 'Kashmiri Red Chilli Pouch (100g)', 'qty': 1, 'price': 100.0},
                            ],
                            totalAmount: 374.0,
                            isDark: isDark,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Download Invoice', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showLiveChatModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Report Issue', style: TextStyle(fontSize: 11, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // FAQ Categories Chip Row
          Text(
            'FREQUENTLY ASKED QUESTIONS',
            style: AppTypography.metadata.copyWith(
              letterSpacing: 1.1,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Delivery', 'Spices', 'Refunds', 'J-Coins', 'Train Delivery'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // FAQ Accordion List
          if (filteredFaqs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'No matching questions found.\nStart a Live Chat with our agent.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(color: isDark ? AppColors.outline : AppColors.lightTextTertiary),
              ),
            )
          else
            ...filteredFaqs.map((faq) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isDark ? AppColors.surfaceContainer : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    iconColor: AppColors.primary,
                    collapsedIconColor: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                    title: Text(
                      faq['question'] as String,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600, 
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    children: [
                      Text(
                        faq['answer'] as String,
                        style: AppTypography.bodySm.copyWith(
                          color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary, 
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );

            }),

          const SizedBox(height: 20),

          // Safety & Guarantee Footer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.sproutGreen, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('100% Purity & Instant Resolution', style: AppTypography.metadata.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        'FSSAI certified facility spices with no adulteration guarantee.',
                        style: AppTypography.metadata.copyWith(color: isDark ? AppColors.outline : AppColors.lightTextTertiary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSupportChannelCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceContainer : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, style: AppTypography.headlineSm.copyWith(fontSize: 13, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.metadata.copyWith(color: isDark ? AppColors.outline : AppColors.lightTextTertiary, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
