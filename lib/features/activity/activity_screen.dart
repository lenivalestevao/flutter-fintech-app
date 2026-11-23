import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/scope.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../../data/wallet_store.dart';

enum Flow { all, income, spending }

sealed class _Row {
  const _Row();
}

final class _Header extends _Row {
  const _Header(this.label, this.total);
  final String label;
  final double total;
}

final class _Item extends _Row {
  const _Item(this.txn);
  final Txn txn;
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _query = '';
  Flow _flow = Flow.all;

  List<_Row> _rows(WalletStore store) {
    final q = _query.trim().toLowerCase();
    final filtered = store.transactions.where((t) {
      final flowOk = switch (_flow) {
        Flow.all => true,
        Flow.income => t.amount > 0,
        Flow.spending => t.amount < 0,
      };
      final queryOk = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.category.label.toLowerCase().contains(q);
      return flowOk && queryOk;
    });

    final groups = <String, List<Txn>>{};
    for (final t in filtered) {
      groups.putIfAbsent(dayLabel(t.date, store.now), () => []).add(t);
    }
    return [
      for (final entry in groups.entries) ...[
        _Header(
          entry.key,
          entry.value.fold(0.0, (sum, t) => sum + t.amount),
        ),
        for (final t in entry.value) _Item(t),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final store = Scope.of<WalletStore>(context);
    final theme = Theme.of(context);
    final rows = _rows(store);

    return MaxWidth(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Activity')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  SearchBar(
                    hintText: 'Search transactions',
                    leading: const Icon(Icons.search_rounded),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<Flow>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: Flow.all, label: Text('All')),
                        ButtonSegment(value: Flow.income, label: Text('Income')),
                        ButtonSegment(
                          value: Flow.spending,
                          label: Text('Spending'),
                        ),
                      ],
                      selected: {_flow},
                      onSelectionChanged: (s) => setState(() => _flow = s.first),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (rows.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No transactions found',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.builder(
                itemCount: rows.length,
                itemBuilder: (context, i) => switch (rows[i]) {
                  _Header h => Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            h.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            money(h.total, sign: true),
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  _Item item => TxnTile(txn: item.txn),
                },
              ),
            ),
        ],
      ),
    );
  }
}
