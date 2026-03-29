import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final bool isSelected;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionTypeModel.income;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: isSelected
            ? const BorderSide(color: AppTheme.primaryColor, width: 1)
            : BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    transaction.category,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category),
                  color: _getCategoryColor(transaction.category),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        if (transaction.isInstallment) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${transaction.installmentCurrent}/${transaction.installmentTotal}x',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatDate(transaction.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'} R\$ ${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isIncome
                      ? AppTheme.secondaryColor
                      : AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getCategoryIcon(TransactionCategoryModel category) {
    switch (category) {
      case TransactionCategoryModel.salary:
        return Icons.work;
      case TransactionCategoryModel.investment:
        return Icons.trending_up;
      case TransactionCategoryModel.food:
        return Icons.restaurant;
      case TransactionCategoryModel.transport:
        return Icons.directions_car;
      case TransactionCategoryModel.entertainment:
        return Icons.movie;
      case TransactionCategoryModel.health:
        return Icons.medical_services;
      case TransactionCategoryModel.education:
        return Icons.school;
      case TransactionCategoryModel.shopping:
        return Icons.shopping_bag;
      case TransactionCategoryModel.bills:
        return Icons.receipt_long;
      case TransactionCategoryModel.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(TransactionCategoryModel category) {
    switch (category) {
      case TransactionCategoryModel.salary:
        return Colors.blue;
      case TransactionCategoryModel.investment:
        return Colors.green;
      case TransactionCategoryModel.food:
        return Colors.orange;
      case TransactionCategoryModel.transport:
        return Colors.purple;
      case TransactionCategoryModel.entertainment:
        return Colors.pink;
      case TransactionCategoryModel.health:
        return Colors.red;
      case TransactionCategoryModel.education:
        return Colors.teal;
      case TransactionCategoryModel.shopping:
        return Colors.amber;
      case TransactionCategoryModel.bills:
        return Colors.brown;
      case TransactionCategoryModel.other:
        return Colors.grey;
    }
  }
}
