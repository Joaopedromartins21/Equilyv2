class Account {
  final String id;
  final String name;
  final double balance;
  final String currency;
  final int color;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    this.currency = 'BRL',
    this.color = 0xFF6C63FF,
  });

  Account copyWith({
    String? id,
    String? name,
    double? balance,
    String? currency,
    int? color,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      color: color ?? this.color,
    );
  }
}
