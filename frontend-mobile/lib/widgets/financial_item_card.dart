import 'package:flutter/material.dart';
import '../models/financial_model.dart';

class FinancialItemCard extends StatelessWidget {
  final FinancialTransaction transaction;
  final VoidCallback onTap;

  const FinancialItemCard({
    Key? key,
    required this.transaction,
    required this.onTap,
  }) : super(key: key);

  Color get _accentColor {
    switch (transaction.category?.toUpperCase()) {
      // INCOME
      case 'COMMON_FEE':
        return const Color(0xFF26A69A); // teal
      case 'RENTAL':
        return const Color(0xFF42A5F5); // blue
      case 'OTHER_INCOME':
        return const Color(0xFF66BB6A); // green
      // EXPENSE
      case 'ELECTRICITY':
        return const Color(0xFFFFB300); // amber
      case 'WATER':
        return const Color(0xFF29B6F6); // light blue
      case 'MAINTENANCE':
        return const Color(0xFFFF7043); // deep orange
      case 'OTHER_EXPENSE':
        return const Color(0xFF8D6E63); // brown
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get _typeIcon {
    switch (transaction.category?.toUpperCase()) {
      // INCOME
      case 'COMMON_FEE':
        return Icons.apartment_rounded;
      case 'RENTAL':
        return Icons.key_rounded;
      case 'OTHER_INCOME':
        return Icons.account_balance_wallet_rounded;
      // EXPENSE
      case 'ELECTRICITY':
        return Icons.bolt_rounded;
      case 'WATER':
        return Icons.water_drop_rounded;
      case 'MAINTENANCE':
        return Icons.build_rounded;
      case 'OTHER_EXPENSE':
        return Icons.receipt_long_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_typeIcon, color: _accentColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.categoryLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            transaction.amountLabel,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            transaction.typeLabel,
                            style: TextStyle(
                              color: _accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatDate(transaction.transactionDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  transaction.getExcerpt(length: 90),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B4B4B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${transaction.attachments.length} ไฟล์แนบ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}