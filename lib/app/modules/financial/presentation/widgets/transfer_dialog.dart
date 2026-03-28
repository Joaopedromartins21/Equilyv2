import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';

class TransferDialog extends StatefulWidget {
  final List<dynamic> accounts;

  const TransferDialog({super.key, required this.accounts});

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  dynamic _fromAccount;
  dynamic _toAccount;

  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) {
      _fromAccount = widget.accounts.first;
      _toAccount = widget.accounts.length > 1
          ? widget.accounts[1]
          : widget.accounts.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_fromAccount.id == _toAccount.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione contas diferentes')),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final now = DateTime.now();

      final expense = TransactionModel(
        id: const Uuid().v4(),
        title: 'Transferência para ${_toAccount.name}',
        amount: amount,
        type: TransactionTypeModel.expense,
        category: TransactionCategoryModel.other,
        date: now,
        accountId: _fromAccount.id,
        description: _descriptionController.text.isEmpty
            ? 'Transferência'
            : _descriptionController.text,
      );

      final income = TransactionModel(
        id: const Uuid().v4(),
        title: 'Transferência de ${_fromAccount.name}',
        amount: amount,
        type: TransactionTypeModel.income,
        category: TransactionCategoryModel.other,
        date: now,
        accountId: _toAccount.id,
        description: _descriptionController.text.isEmpty
            ? 'Transferência'
            : _descriptionController.text,
      );

      Navigator.pop(context, {
        'expense': expense,
        'income': income,
        'from': _fromAccount,
        'to': _toAccount,
        'amount': amount,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.swap_horiz,
                    size: 28,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Transferência',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (widget.accounts.length >= 2) ...[
                DropdownButtonFormField<dynamic>(
                  value: _fromAccount,
                  decoration: const InputDecoration(
                    labelText: 'De:',
                    prefixIcon: Icon(Icons.arrow_outward),
                  ),
                  items: widget.accounts
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _fromAccount = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<dynamic>(
                  value: _toAccount,
                  decoration: const InputDecoration(
                    labelText: 'Para:',
                    prefixIcon: Icon(Icons.call_received),
                  ),
                  items: widget.accounts
                      .where((a) => a.id != _fromAccount?.id)
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _toAccount = v),
                ),
              ] else
                const Text(
                  'Cadastre pelo menos 2 contas para fazer transferências',
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Preencha o valor' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Observação (opcional)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Transferir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
