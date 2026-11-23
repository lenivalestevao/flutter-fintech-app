# 💳 Flutter Fintech Wallet

A free Flutter template for a modern digital wallet: balance, quick actions, activity feed with search and filters, cards you can freeze, spending insights with charts, and a send-money flow with a custom keypad. Material 3, light and dark themes, **no third-party packages**.

## Features

- **Home**: balance card (tap the eye to hide it), quick actions, 7-day spending bar chart, recent activity
- **Activity**: search, All / Income / Spending filter, grouped by day with daily totals, tap a transaction for details
- **Cards**: swipeable cards, freeze and unfreeze, show number, monthly limit slider
- **Insights**: animated donut chart by category (7 or 30 days) and monthly budgets that warn when you are close or over
- **Send money**: pick a contact, custom keypad (2 decimals max), note, review sheet, success screen
- **Adaptive**: bottom bar on phones, navigation rail on tablets, desktop and web
- Light and dark themes generated from one seed color

## Modern Flutter / Dart used

- Dart 3: records, pattern matching, `switch` expressions, sealed classes (`SendResult`) and enhanced enums (`Category`)
- Material 3 widgets: `NavigationBar`, `NavigationRail`, `SearchBar`, `SegmentedButton`, `SliverAppBar.large`, `Badge`
- `Color.withValues`, `WidgetStatePropertyAll`, `surfaceContainer*` roles (no deprecated APIs)
- Predictive back transitions on Android
- Custom charts with `CustomPainter` (bars and donut), no chart package
- State with a plain `ChangeNotifier` exposed by a tiny `Scope` (`InheritedNotifier`), injectable clock for tests

## Run it

```bash
flutter create . --platforms=android,ios,web
flutter pub get
flutter run
```

`flutter create .` only adds the platform folders. It keeps the `lib/` and `pubspec.yaml` of this repo. Needs Flutter 3.32 or newer.

## Structure

| Path | Purpose |
|---|---|
| `lib/main.dart` | App entry, theme and store |
| `lib/core/` | Theme, formatting, `Scope`, charts, shared widgets |
| `lib/data/models.dart` | Models, `Category` enum, `SendResult` |
| `lib/data/wallet_store.dart` | State, queries and actions (with sample data) |
| `lib/features/` | One folder per screen: home, activity, cards, insights, send |
| `test/widget_test.dart` | Store logic and UI tests |

## Make it yours

1. Change `brand` in `lib/core/theme.dart` and the name in `lib/main.dart`.
2. Edit the sample data in `WalletStore._seed`, `contacts`, `budgets` and `_cards`.
3. Connect your backend: make `send` call your API and load transactions in the store. The screens only use the store's getters and methods.
4. Prefer Riverpod or Bloc? Replace `Scope` and `WalletStore`; the widgets read state in one line each.

## Notes

- Everything is a demo. Money, names and card numbers are fictional and nothing is sent anywhere. Data is kept in memory only.
- This code was written without a Flutter SDK available, so it has not been compiled yet. Run `flutter analyze` and `flutter test` first. If you hit an error, please open an issue.

## License

MIT. Use it for personal and commercial projects.
