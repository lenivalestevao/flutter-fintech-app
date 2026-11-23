import 'package:flutter/material.dart';

/// Enhanced enum (Dart 3): each category carries its own label, icon and color.
enum Category {
  food('Food', Icons.restaurant_rounded, Color(0xFFFF8A65)),
  transport('Transport', Icons.directions_bus_rounded, Color(0xFF4FC3F7)),
  shopping('Shopping', Icons.shopping_bag_rounded, Color(0xFFBA68C8)),
  bills('Bills', Icons.receipt_long_rounded, Color(0xFFFFD54F)),
  leisure('Leisure', Icons.movie_rounded, Color(0xFF81C784)),
  income('Income', Icons.south_west_rounded, Color(0xFF26A69A)),
  transfer('Transfer', Icons.swap_horiz_rounded, Color(0xFF90A4AE));

  const Category(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class Txn {
  const Txn({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note = '',
  });

  final String id;
  final String title;

  /// Negative = money out, positive = money in.
  final double amount;
  final DateTime date;
  final Category category;
  final String note;

  bool get isIncome => amount > 0;
}

class Contact {
  const Contact({required this.name, required this.handle, required this.color});

  final String name;
  final String handle;
  final Color color;

  String get initials {
    final parts = name.split(' ');
    return parts.take(2).map((p) => p[0]).join();
  }
}

class Budget {
  const Budget(this.category, this.limit);

  final Category category;
  final double limit;
}

enum CardBrand { visa, mastercard }

class BankCard {
  const BankCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holder,
    required this.expiry,
    required this.colors,
    required this.monthlyLimit,
    required this.spent,
    this.frozen = false,
  });

  final String id;
  final CardBrand brand;
  final String last4;
  final String holder;
  final String expiry;
  final List<Color> colors;
  final double monthlyLimit;
  final double spent;
  final bool frozen;

  BankCard copyWith({bool? frozen, double? monthlyLimit}) => BankCard(
        id: id,
        brand: brand,
        last4: last4,
        holder: holder,
        expiry: expiry,
        colors: colors,
        monthlyLimit: monthlyLimit ?? this.monthlyLimit,
        spent: spent,
        frozen: frozen ?? this.frozen,
      );
}

/// Result of a transfer. A sealed class makes the UI handle every outcome.
sealed class SendResult {
  const SendResult();
}

final class Sent extends SendResult {
  const Sent(this.txn);
  final Txn txn;
}

final class Rejected extends SendResult {
  const Rejected(this.reason);
  final String reason;
}
