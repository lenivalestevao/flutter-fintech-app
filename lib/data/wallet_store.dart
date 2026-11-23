import 'package:flutter/material.dart';

import '../core/format.dart';
import 'models.dart';

/// All app state in one plain [ChangeNotifier]. Replace it with Riverpod, Bloc
/// or a real API client when you connect a backend; the screens only call the
/// public methods and getters below.
class WalletStore extends ChangeNotifier {
  WalletStore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    _seed();
  }

  final DateTime Function() _clock;
  final List<Txn> _txns = [];

  static const double openingBalance = 1800;
  static const double sendLimit = 5000;

  DateTime get now => _clock();

  bool _hideBalance = false;
  bool get hideBalance => _hideBalance;
  void toggleHideBalance() {
    _hideBalance = !_hideBalance;
    notifyListeners();
  }

  // ---------------------------------------------------------------- data

  List<Txn> get transactions => List.unmodifiable(_txns);

  double get balance => _txns.fold(openingBalance, (sum, t) => sum + t.amount);

  late final List<Contact> contacts = const [
    Contact(name: 'Ana Souza', handle: '@ana', color: Color(0xFFEF5350)),
    Contact(name: 'Marcus Lee', handle: '@marcus', color: Color(0xFF42A5F5)),
    Contact(name: 'Priya Patel', handle: '@priya', color: Color(0xFFAB47BC)),
    Contact(name: 'Diego Ramos', handle: '@diego', color: Color(0xFFFFA726)),
    Contact(name: 'Emma Clark', handle: '@emma', color: Color(0xFF26A69A)),
    Contact(name: 'Yuki Tanaka', handle: '@yuki', color: Color(0xFF7E57C2)),
  ];

  final List<Budget> budgets = const [
    Budget(Category.food, 400),
    Budget(Category.transport, 150),
    Budget(Category.shopping, 250),
    Budget(Category.leisure, 120),
    Budget(Category.bills, 1500),
  ];

  List<BankCard> _cards = const [
    BankCard(
      id: 'c1',
      brand: CardBrand.visa,
      last4: '4821',
      holder: 'LENI JUNIOR',
      expiry: '09/29',
      colors: [Color(0xFF3F3DDB), Color(0xFF8E5CF7)],
      monthlyLimit: 3000,
      spent: 1180,
    ),
    BankCard(
      id: 'c2',
      brand: CardBrand.mastercard,
      last4: '9307',
      holder: 'LENI JUNIOR',
      expiry: '02/28',
      colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
      monthlyLimit: 1500,
      spent: 412,
    ),
  ];
  List<BankCard> get cards => List.unmodifiable(_cards);

  // ------------------------------------------------------------- queries

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Money out per day for the last [days] days, oldest first (positive numbers).
  List<double> dailySpending({int days = 7}) {
    final today = _startOfDay(now);
    return [
      for (var i = days - 1; i >= 0; i--)
        _txns
            .where((t) =>
                t.amount < 0 &&
                _startOfDay(t.date) == today.subtract(Duration(days: i)))
            .fold(0.0, (sum, t) => sum - t.amount),
    ];
  }

  bool _inLast(Txn t, int days) {
    final from = _startOfDay(now).subtract(Duration(days: days - 1));
    return !t.date.isBefore(from);
  }

  double income({int days = 30}) => _txns
      .where((t) => t.amount > 0 && _inLast(t, days))
      .fold(0.0, (sum, t) => sum + t.amount);

  double spent({int days = 30}) => _txns
      .where((t) => t.amount < 0 && _inLast(t, days))
      .fold(0.0, (sum, t) => sum - t.amount);

  double spentIn(Category category, {int days = 30}) => _txns
      .where((t) => t.amount < 0 && t.category == category && _inLast(t, days))
      .fold(0.0, (sum, t) => sum - t.amount);

  /// Spending by category, biggest first.
  List<({Category category, double value})> spendingByCategory({int days = 30}) {
    final list = [
      for (final c in Category.values)
        if (c != Category.income)
          (category: c, value: spentIn(c, days: days)),
    ].where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  // ------------------------------------------------------------- actions

  SendResult send({
    required Contact to,
    required double amount,
    String note = '',
  }) {
    if (amount <= 0) return const Rejected('Enter an amount greater than zero.');
    if (amount > sendLimit) {
      return Rejected('The limit per transfer is ${money(sendLimit)}.');
    }
    if (amount > balance) {
      return Rejected('Not enough balance. You have ${money(balance)}.');
    }
    final txn = Txn(
      id: 't${_txns.length + 1}',
      title: 'To ${to.name}',
      amount: -amount,
      date: now,
      category: Category.transfer,
      note: note,
    );
    _txns.insert(0, txn);
    notifyListeners();
    return Sent(txn);
  }

  void toggleFreeze(String cardId) {
    _cards = [
      for (final c in _cards)
        if (c.id == cardId) c.copyWith(frozen: !c.frozen) else c,
    ];
    notifyListeners();
  }

  void setLimit(String cardId, double limit) {
    _cards = [
      for (final c in _cards)
        if (c.id == cardId) c.copyWith(monthlyLimit: limit) else c,
    ];
    notifyListeners();
  }

  // ---------------------------------------------------------------- seed

  void _seed() {
    const rows = <(String, double, int, int, Category)>[
      ('Blue Bottle Coffee', -4.80, 0, 8, Category.food),
      ('Metro card top-up', -20.00, 0, 9, Category.transport),
      ('Spotify', -10.99, 1, 7, Category.leisure),
      ('Whole Foods', -63.42, 1, 18, Category.food),
      ('Uber', -18.30, 2, 22, Category.transport),
      ('Amazon', -42.99, 2, 14, Category.shopping),
      ('Freelance - Studio Lume', 850.00, 3, 10, Category.income),
      ('Netflix', -15.49, 4, 6, Category.leisure),
      ('Shell Gas', -48.10, 4, 17, Category.transport),
      ('Chipotle', -12.75, 5, 13, Category.food),
      ('Zara', -79.90, 6, 16, Category.shopping),
      ('Electric bill', -86.20, 8, 11, Category.bills),
      ('Rent', -1250.00, 9, 9, Category.bills),
      ('Cinema', -24.00, 10, 20, Category.leisure),
      ('Salary - Acme Inc.', 4200.00, 12, 9, Category.income),
      ("Trader Joe's", -54.18, 12, 18, Category.food),
      ('Lyft', -14.60, 13, 23, Category.transport),
      ('Gym membership', -39.00, 15, 7, Category.bills),
      ('Sushi Zen', -46.50, 16, 20, Category.food),
      ('Nike', -120.00, 18, 15, Category.shopping),
      ('Internet', -59.99, 20, 10, Category.bills),
      ('Concert tickets', -95.00, 22, 12, Category.leisure),
      ('Whole Foods', -71.05, 24, 18, Category.food),
      ('Refund - Amazon', 29.99, 26, 11, Category.income),
      ('Train ticket', -36.00, 27, 8, Category.transport),
    ];
    final today = now;
    for (var i = 0; i < rows.length; i++) {
      final (title, amount, daysAgo, hour, category) = rows[i];
      _txns.add(Txn(
        id: 't${i + 1}',
        title: title,
        amount: amount,
        date: DateTime(
          today.year,
          today.month,
          today.day - daysAgo,
          hour,
          (i * 17) % 60,
        ),
        category: category,
      ));
    }
    _txns.sort((a, b) => b.date.compareTo(a.date));
  }
}
