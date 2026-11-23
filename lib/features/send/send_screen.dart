import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/scope.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../../data/wallet_store.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _note = TextEditingController();
  Contact? _to;
  String _raw = '';
  Txn? _done;

  double get _amount => double.tryParse(_raw) ?? 0;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _press(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == '<') {
        if (_raw.isNotEmpty) _raw = _raw.substring(0, _raw.length - 1);
        return;
      }
      if (key == '.') {
        if (_raw.contains('.')) return;
        _raw = _raw.isEmpty ? '0.' : '$_raw.';
        return;
      }
      final dot = _raw.indexOf('.');
      if (dot != -1 && _raw.length - dot > 2) return; // max 2 decimals
      if (dot == -1 && _raw.length >= 6) return; // max 6 whole digits
      _raw = _raw == '0' ? key : '$_raw$key';
    });
  }

  Future<void> _review() async {
    final store = Scope.read<WalletStore>(context);
    final to = _to!;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _ReviewSheet(
        to: to,
        amount: _amount,
        note: _note.text.trim(),
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = store.send(to: to, amount: _amount, note: _note.text.trim());
    switch (result) {
      case Sent(:final txn):
        setState(() => _done = txn);
      case Rejected(:final reason):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(reason)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _done;
    if (done != null) {
      return _SuccessView(txn: done, to: _to!);
    }

    final store = Scope.of<WalletStore>(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final canReview = _to != null && _amount > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: SafeArea(
        child: MaxWidth(
          width: 520,
          child: Column(
            children: [
              SizedBox(
                height: 96,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: store.contacts.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final c = store.contacts[i];
                    final selected = _to == c;
                    return InkWell(
                      onTap: () => setState(() => _to = c),
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 64,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: selected
                                      ? scheme.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: c.color,
                                foregroundColor: Colors.white,
                                child: Text(c.initials),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.name.split(' ').first,
                              style: theme.textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${_raw.isEmpty ? '0' : _raw}',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _raw.isEmpty
                            ? scheme.onSurface.withValues(alpha: 0.35)
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Available ${money(store.balance)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
                      child: TextField(
                        controller: _note,
                        textAlign: TextAlign.center,
                        maxLength: 40,
                        decoration: const InputDecoration(
                          hintText: 'Add a note (optional)',
                          counterText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _Keypad(onKey: _press),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canReview ? _review : null,
                    child: Text(_to == null ? 'Choose a recipient' : 'Review'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _keys = [
    '1', '2', '3', //
    '4', '5', '6',
    '7', '8', '9',
    '.', '0', '<',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        children: [
          for (final key in _keys)
            InkResponse(
              onTap: () => onKey(key),
              radius: 36,
              child: Center(
                child: key == '<'
                    ? const Icon(Icons.backspace_outlined)
                    : Text(
                        key,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewSheet extends StatelessWidget {
  const _ReviewSheet({required this.to, required this.amount, required this.note});

  final Contact to;
  final double amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: to.color,
            foregroundColor: Colors.white,
            child: Text(to.initials, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 12),
          Text('Send to ${to.name}', style: theme.textTheme.titleMedium),
          Text(to.handle, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Text(
            money(amount),
            style: theme.textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('"$note"', style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 8),
          Text('Fee: \$0.00 · Arrives instantly', style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm and send'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.txn, required this.to});

  final Txn txn;
  final Contact to;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: const Icon(Icons.check_rounded, size: 56),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Sent!', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '${money(-txn.amount)} is on its way to ${to.name}.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 280,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
