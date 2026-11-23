import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_wallet/data/models.dart';
import 'package:nova_wallet/data/wallet_store.dart';
import 'package:nova_wallet/main.dart';

void main() {
  final fixedNow = DateTime(2026, 11, 20, 12);
  WalletStore makeStore() => WalletStore(clock: () => fixedNow);

  group('WalletStore', () {
    test('balance is opening balance plus all transactions', () {
      final store = makeStore();
      final sum = store.transactions.fold(0.0, (s, t) => s + t.amount);
      expect(store.balance, closeTo(WalletStore.openingBalance + sum, 0.001));
    });

    test('send moves money out and adds a transaction', () {
      final store = makeStore();
      final before = store.balance;
      final result = store.send(to: store.contacts.first, amount: 25);
      expect(result, isA<Sent>());
      expect(store.balance, closeTo(before - 25, 0.001));
      expect(store.transactions.first.amount, -25);
    });

    test('send rejects zero and more than the balance', () {
      final store = makeStore();
      expect(store.send(to: store.contacts.first, amount: 0), isA<Rejected>());
      expect(
        store.send(to: store.contacts.first, amount: store.balance + 1),
        isA<Rejected>(),
      );
    });

    test('dailySpending returns one value per day', () {
      expect(makeStore().dailySpending(days: 7), hasLength(7));
    });

    test('toggleFreeze flips the card state', () {
      final store = makeStore();
      final id = store.cards.first.id;
      store.toggleFreeze(id);
      expect(store.cards.first.frozen, isTrue);
    });
  });

  group('App', () {
    testWidgets('shows the balance and can hide it', (tester) async {
      await tester.pumpWidget(NovaApp(store: makeStore()));
      await tester.pumpAndSettle();

      expect(find.text('Total balance'), findsOneWidget);
      await tester.tap(find.byTooltip('Hide balance'));
      await tester.pumpAndSettle();
      expect(find.text('••••••'), findsOneWidget);
    });

    testWidgets('navigates to the cards tab', (tester) async {
      await tester.pumpWidget(NovaApp(store: makeStore()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.credit_card_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Freeze card'), findsOneWidget);
    });
  });
}
