import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class CreditCardModel {
  final String id;
  final String name;
  final String? last4Digits;
  final int closingDay;
  final int dueDay;
  final double creditLimit;
  final String? brand;
  double currentSpend;

  CreditCardModel({
    required this.id,
    required this.name,
    this.last4Digits,
    required this.closingDay,
    required this.dueDay,
    this.creditLimit = 0,
    this.brand,
    this.currentSpend = 0,
  });

  double get availableCredit => creditLimit - currentSpend;
  double get usagePercent =>
      creditLimit > 0 ? (currentSpend / creditLimit) * 100 : 0;
}

class CreditCardsPanel extends StatefulWidget {
  final List<CreditCardModel> cards;
  final Function(CreditCardModel) onAddCard;
  final Function(String) onRemoveCard;

  const CreditCardsPanel({
    super.key,
    required this.cards,
    required this.onAddCard,
    required this.onRemoveCard,
  });

  @override
  State<CreditCardsPanel> createState() => _CreditCardsPanelState();
}

class _CreditCardsPanelState extends State<CreditCardsPanel> {
  void _showAddCardDialog() {
    final nameController = TextEditingController();
    final last4Controller = TextEditingController();
    final limitController = TextEditingController();
    int closingDay = 15;
    int dueDay = 25;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo Cartão de Crédito'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do cartão',
                    hintText: 'Ex: Nubank, Itaú',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: last4Controller,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Últimos 4 dígitos',
                    hintText: '1234',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Limite de crédito',
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: closingDay,
                        decoration: const InputDecoration(
                          labelText: 'Dia de fechamento',
                        ),
                        items: List.generate(28, (i) => i + 1)
                            .map(
                              (d) =>
                                  DropdownMenuItem(value: d, child: Text('$d')),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => closingDay = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: dueDay,
                        decoration: const InputDecoration(
                          labelText: 'Dia de vencimento',
                        ),
                        items: List.generate(28, (i) => i + 1)
                            .map(
                              (d) =>
                                  DropdownMenuItem(value: d, child: Text('$d')),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => dueDay = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;
                final card = CreditCardModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  last4Digits: last4Controller.text.isNotEmpty
                      ? last4Controller.text
                      : null,
                  closingDay: closingDay,
                  dueDay: dueDay,
                  creditLimit: double.tryParse(limitController.text) ?? 0,
                );
                widget.onAddCard(card);
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Cartões de Crédito',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddCardDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.cards.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum cartão cadastrado',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.cards.length,
              itemBuilder: (context, index) {
                final card = widget.cards[index];
                final isHighUsage = card.usagePercent > 80;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCardColor(card.brand).withValues(alpha: 0.8),
                        _getCardColor(card.brand),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              card.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white70,
                              size: 18,
                            ),
                            onPressed: () => widget.onRemoveCard(card.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        card.last4Digits != null
                            ? '•••• ${card.last4Digits}'
                            : '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(card.currentSpend),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (card.creditLimit > 0) ...[
                        LinearProgressIndicator(
                          value: card.usagePercent / 100,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation(
                            isHighUsage ? Colors.red : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Limite: ${currencyFormat.format(card.creditLimit)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getCardColor(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return Colors.indigo;
      case 'mastercard':
        return Colors.orange;
      case 'amex':
        return Colors.blue;
      default:
        return AppTheme.primaryColor;
    }
  }
}
