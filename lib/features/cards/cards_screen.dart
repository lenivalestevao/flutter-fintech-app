import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/scope.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../../data/wallet_store.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _controller = PageController(viewportFraction: 0.9);
  int _index = 0;
  bool _reveal = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = Scope.of<WalletStore>(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cards = store.cards;
    final card = cards[_index];
    final usage = (card.spent / card.monthlyLimit).clamp(0.0, 1.0).toDouble();

    return MaxWidth(
      width: 560,
      child: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Cards')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 214,
              child: PageView.builder(
                controller: _controller,
                itemCount: cards.length,
                onPageChanged: (i) => setState(() {
                  _index = i;
                  _reveal = false;
                }),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Center(
                    child: CardView(card: cards[i], reveal: _reveal && i == _index),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < cards.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: i == _index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: i == _index
                          ? scheme.primary
                          : scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: SliverList.list(
              children: [
                Card(
                  elevation: 0,
                  color: scheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.ac_unit_rounded),
                        title: const Text('Freeze card'),
                        subtitle: const Text('Block all payments instantly'),
                        value: card.frozen,
                        onChanged: (_) => store.toggleFreeze(card.id),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.pin_outlined),
                        title: const Text('Show card number'),
                        value: _reveal,
                        onChanged: (v) => setState(() => _reveal = v),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Monthly limit',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const Spacer(),
                                Text(
                                  money(card.monthlyLimit),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              min: 500,
                              max: 5000,
                              divisions: 18,
                              label: money(card.monthlyLimit),
                              value: card.monthlyLimit.clamp(500.0, 5000.0).toDouble(),
                              onChanged: (v) => store.setLimit(card.id, v),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: usage,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${money(card.spent)} spent this month',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
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

class CardView extends StatelessWidget {
  const CardView({super.key, required this.card, this.reveal = false});

  final BankCard card;
  final bool reveal;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    const white = Colors.white;
    final number = reveal ? '4532 8891 0027 ${card.last4}' : '•••• •••• •••• ${card.last4}';

    return AspectRatio(
      aspectRatio: 1.586,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: card.colors,
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'NOVA',
                        style: style.titleMedium?.copyWith(
                          color: white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.contactless_rounded, color: white),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    number,
                    style: style.titleLarge?.copyWith(
                      color: white,
                      letterSpacing: 2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.holder,
                          style: style.labelMedium?.copyWith(color: white),
                        ),
                      ),
                      Text(
                        card.expiry,
                        style: style.labelMedium?.copyWith(color: white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        card.brand == CardBrand.visa ? 'VISA' : 'MC',
                        style: style.titleMedium?.copyWith(
                          color: white,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (card.frozen)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ac_unit_rounded, color: white, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'Card frozen',
                      style: TextStyle(color: white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
