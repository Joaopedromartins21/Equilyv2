import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryManagement extends StatefulWidget {
  final Map<String, double>? categoryLimits;
  final Function(Map<String, double>) onLimitsChanged;

  const CategoryManagement({
    super.key,
    this.categoryLimits,
    required this.onLimitsChanged,
  });

  @override
  State<CategoryManagement> createState() => _CategoryManagementState();
}

class _CategoryManagementState extends State<CategoryManagement> {
  late Map<String, TextEditingController> _controllers;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Alimentação', 'icon': Icons.restaurant, 'color': Colors.orange},
    {
      'name': 'Transporte',
      'icon': Icons.directions_car,
      'color': Colors.purple,
    },
    {'name': 'Entretenimento', 'icon': Icons.movie, 'color': Colors.pink},
    {'name': 'Saúde', 'icon': Icons.medical_services, 'color': Colors.red},
    {'name': 'Educação', 'icon': Icons.school, 'color': Colors.teal},
    {'name': 'Compras', 'icon': Icons.shopping_bag, 'color': Colors.amber},
    {'name': 'Contas', 'icon': Icons.receipt_long, 'color': Colors.brown},
    {'name': 'Outros', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (var cat in _categories) {
      final key = cat['name'] as String;
      final limit = widget.categoryLimits?[key] ?? 0.0;
      _controllers[key] = TextEditingController(
        text: limit > 0 ? limit.toStringAsFixed(2) : '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveLimits() {
    final limits = <String, double>{};
    for (var entry in _controllers.entries) {
      final value = double.tryParse(entry.value.text);
      if (value != null && value > 0) {
        limits[entry.key] = value;
      }
    }
    widget.onLimitsChanged(limits);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Limites salvos com sucesso!')),
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
                'Limites por Categoria',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveLimits,
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Defina um limite mensal para cada categoria. Você receberá um alerta quando o gasto ultrapassar 80% do limite.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final name = cat['name'] as String;
              final icon = cat['icon'] as IconData;
              final color = cat['color'] as Color;
              final controller = _controllers[name]!;

              final currentLimit = double.tryParse(controller.text) ?? 0;
              final hasLimit = currentLimit > 0;

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasLimit
                      ? color.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: hasLimit
                        ? color.withValues(alpha: 0.3)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasLimit ? color : Colors.grey.shade600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Limite',
                              hintStyle: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
