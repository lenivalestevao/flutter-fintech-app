import 'package:flutter/material.dart';

import '../../core/charts.dart';
import '../../core/format.dart';
import '../../core/scope.dart';
import '../../core/widgets.dart';
import '../../data/wallet_store.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final store = Scope.of<WalletStore>(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final byCategory = store.spendingByCategory(days: _days);
    final total = byCategory.fold(0.0, (sum, e) => sum + e.value);

    return MaxWidth(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Insights')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.list(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 7, label: Text('7 days')),
                      ButtonSegment(value: 30, label: Text('30 days')),
                    ],
                    selected: {_days},
                    onSelectionChanged: (s) => setState(() => _days = s.first),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(_days),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, progress, child) => Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: DonutPainter(
                            slices: [
                              for (final e in byCategory)
                                DonutSlice(e.value, e.category.color),
                            ],
                            trackColor: scheme.surfaceContainerHighest,
                            progress: progress,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Spent', style: theme.textTheme.labelMedium),
                            Text(
                              money(total),
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final e in byCategory)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: e.category.color.withValues(alpha: 0.18),
                      foregroundColor: e.category.color,
                      child: Icon(e.category.icon, size: 16),
                    ),
                    title: Text(e.category.label),
                    subtitle: Text('${(e.value / total * 100).round()}%'),
                    trailing: Text(
                      money(e.value),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                const SectionHeader('Monthly budgets'),
                for (final budget in store.budgets)
                  _BudgetTile(
                    label: budget.category.label,
                    color: budget.category.color,
                    spent: store.spentIn(budget.category),
                    limit: budget.limit,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.label,
    required this.color,
    required this.spent,
    required this.limit,
  });

  final String label;
  final Color color;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = spent / limit;
    final over = ratio >= 1;
    final barColor = over
        ? theme.colorScheme.error
        : ratio >= 0.8
            ? theme.colorScheme.tertiary
            : color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: theme.textTheme.titleSmall),
              const Spacer(),
              Text(
                '${money(spent)} / ${money(limit)}',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0).toDouble(),
              minHeight: 10,
              color: barColor,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          if (over)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Over budget by ${money(spent - limit)}',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
