import 'package:flutter/material.dart';

import '../data/models.dart';
import 'format.dart';
import 'theme.dart';

class TxnTile extends StatelessWidget {
  const TxnTile({super.key, required this.txn});

  final Txn txn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: () => showTxnDetails(context, txn),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: txn.category.color.withValues(alpha: 0.18),
        foregroundColor: txn.category.color,
        child: Icon(txn.category.icon),
      ),
      title: Text(txn.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${txn.category.label} · ${timeLabel(txn.date)}'),
      trailing: Text(
        money(txn.amount, sign: true),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: txn.isIncome ? AppTheme.positive : scheme.onSurface,
        ),
      ),
    );
  }
}

Future<void> showTxnDetails(BuildContext context, Txn txn) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      Widget row(String label, String value) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                const Spacer(),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: txn.category.color.withValues(alpha: 0.18),
              foregroundColor: txn.category.color,
              child: Icon(txn.category.icon, size: 28),
            ),
            const SizedBox(height: 12),
            Text(txn.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              money(txn.amount, sign: true),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            const Divider(),
            row('Category', txn.category.label),
            row('Date', '${weekdayShort(txn.date)} · ${timeLabel(txn.date)}'),
            row('Status', 'Completed'),
            if (txn.note.isNotEmpty) row('Note', txn.note),
            row('Reference', txn.id.toUpperCase()),
          ],
        ),
      );
    },
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

/// Centers content and caps its width so the layout also works on tablets,
/// desktop and web.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.width = 720});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: child,
      ),
    );
  }
}
