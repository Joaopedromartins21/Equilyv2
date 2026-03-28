import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/database_service.dart';

class InstallmentsPanel extends StatelessWidget {
  final VoidCallback onRefresh;

  const InstallmentsPanel({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final allTransactions = DatabaseService.transactions.values.toList();
    final installments = allTransactions
        .where(
          (t) => t.isInstallment && t.installmentCurrent! < t.installmentTotal!,
        )
        .toList();
    installments.sort((a, b) => a.date.compareTo(b.date));

    final totalPending = installments.fold(0.0, (sum, t) => sum + t.amount);
    final nextPayment = installments.isNotEmpty ? installments.first : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total de Parcelas Pendentes',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'R\$ ${totalPending.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${installments.length} parcelas em aberto',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (nextPayment != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Próxima',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${nextPayment.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${nextPayment.date.day}/${nextPayment.date.month}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: installments.isEmpty
                    ? _buildEmptyState()
                    : _buildInstallmentsList(installments),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhuma compra parcelada',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas parcelas aparecerão aqui',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentsList(List<TransactionModel> installments) {
    final groupedByPurchase = <String, List<TransactionModel>>{};
    final accounts = DatabaseService.accounts.values.toList();

    for (var t in installments) {
      final key = t.title.replaceAll(RegExp(r'\s\(\d+/\d+\)'), '');
      groupedByPurchase.putIfAbsent(key, () => []).add(t);
    }

    return ListView.builder(
      itemCount: groupedByPurchase.length,
      itemBuilder: (context, index) {
        final purchaseName = groupedByPurchase.keys.elementAt(index);
        final items = groupedByPurchase[purchaseName]!;
        final total = items.fold(0.0, (sum, t) => sum + t.amount);
        final paid = items.first.installmentTotal! - items.length;
        final totalInstallments = items.first.installmentTotal!;
        final accountId = items.first.accountId;
        final account = accounts.where((a) => a.id == accountId).firstOrNull;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: account != null
                        ? Color(account.color).withValues(alpha: 0.1)
                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: account != null
                        ? Color(account.color)
                        : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchaseName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$paid/${totalInstallments}x pago',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${items.length}x restante',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (account != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(
                                  account.color,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                account.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(account.color),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: paid / totalInstallments,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.green,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'restante',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
