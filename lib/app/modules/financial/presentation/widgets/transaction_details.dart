import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';

class TransactionDetails extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetails({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionTypeModel.income;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isIncome ? AppTheme.secondaryColor : AppTheme.errorColor)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? AppTheme.secondaryColor : AppTheme.errorColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIncome ? 'Receita' : 'Despesa',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    'R\$ ${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isIncome
                          ? AppTheme.secondaryColor
                          : AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailRow('Descrição', transaction.title),
        _buildDetailRow('Categoria', _getCategoryName(transaction.category)),
        _buildDetailRow('Data', _formatDate(transaction.date)),
        if (transaction.isInstallment)
          _buildDetailRow(
            'Parcela',
            '${transaction.installmentCurrent} de ${transaction.installmentTotal}',
          ),
        if (transaction.description != null &&
            transaction.description!.isNotEmpty)
          _buildDetailRow('Observação', transaction.description!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _getCategoryName(TransactionCategoryModel category) {
    switch (category) {
      case TransactionCategoryModel.salary:
        return 'Salário';
      case TransactionCategoryModel.investment:
        return 'Investimento';
      case TransactionCategoryModel.food:
        return 'Alimentação';
      case TransactionCategoryModel.transport:
        return 'Transporte';
      case TransactionCategoryModel.entertainment:
        return 'Entretenimento';
      case TransactionCategoryModel.health:
        return 'Saúde';
      case TransactionCategoryModel.education:
        return 'Educação';
      case TransactionCategoryModel.shopping:
        return 'Compras';
      case TransactionCategoryModel.bills:
        return 'Contas';
      case TransactionCategoryModel.other:
        return 'Outros';
    }
  }
}
