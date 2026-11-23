import 'package:flutter/material.dart';

import '../../core/charts.dart';
import '../../core/format.dart';
import '../../core/scope.dart';
import '../../core/widgets.dart';
import '../../data/wallet_store.dart';
import '../send/send_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  String _greeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final store = Scope.of<WalletStore>(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final recent = store.transactions.take(5).toList();

    return MaxWidth(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            titleSpacing: 20,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: const Text('L'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(store.now.hour),
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      'Leni',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {},
                icon: const Badge(
                  smallSize: 8,
                  child: Icon(Icons.notifications_none_rounded),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList.list(
              children: [
                const _BalanceCard(),
                const SizedBox(height: 20),
                const _QuickActions(),
                const SectionHeader('Spending'),
                const _SpendingCard(),
                SectionHeader(
                  'Recent activity',
                  action: 'See all',
                  onAction: onSeeAll,
                ),
                for (final txn in recent) TxnTile(txn: txn),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final store = Scope.of<WalletStore>(context);
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hidden = store.hideBalance;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.tertiary, 0.6)!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total balance',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.85)),
              ),
              const Spacer(),
              IconButton(
                tooltip: hidden ? 'Show balance' : 'Hide balance',
                color: scheme.onPrimary,
                onPressed: store.toggleHideBalance,
                icon: Icon(
                  hidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              hidden ? '••••••' : money(store.balance),
              key: ValueKey(hidden),
              style: theme.textTheme.displaySmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Pill(
                  icon: Icons.south_west_rounded,
                  label: 'Income',
                  value: hidden ? '••••' : money(store.income()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Pill(
                  icon: Icons.north_east_rounded,
                  label: 'Spent',
                  value: hidden ? '••••' : money(store.spent()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.8)),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  void _demo(BuildContext context, String name) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$name is a demo screen.')));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(
          icon: Icons.north_east_rounded,
          label: 'Send',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SendScreen()),
          ),
        ),
        _Action(
          icon: Icons.south_west_rounded,
          label: 'Request',
          onTap: () => _demo(context, 'Request'),
        ),
        _Action(
          icon: Icons.add_rounded,
          label: 'Top up',
          onTap: () => _demo(context, 'Top up'),
        ),
        _Action(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scan',
          onTap: () => _demo(context, 'Scan'),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: scheme.onSecondaryContainer),
              ),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpendingCard extends StatelessWidget {
  const _SpendingCard();

  @override
  Widget build(BuildContext context) {
    final store = Scope.of<WalletStore>(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final values = store.dailySpending(days: 7);
    final total = values.fold(0.0, (a, b) => a + b);
    final today = store.now;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 7 days', style: theme.textTheme.labelMedium),
            Text(
              money(total),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, progress, child) => CustomPaint(
                  size: Size.infinite,
                  painter: BarChartPainter(
                    values: values,
                    barColor: scheme.primary.withValues(alpha: 0.45),
                    highlightColor: scheme.primary,
                    trackColor: scheme.surfaceContainerHighest,
                    progress: progress,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 6; i >= 0; i--)
                  Expanded(
                    child: Text(
                      weekdayShort(today.subtract(Duration(days: i))),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
