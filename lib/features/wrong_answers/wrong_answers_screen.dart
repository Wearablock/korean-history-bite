// lib/features/wrong_answers/wrong_answers_screen.dart

import 'package:flutter/material.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../core/widgets/collapsing_app_bar_scaffold.dart';

class WrongAnswersScreen extends StatelessWidget {
  const WrongAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CollapsingAppBarScaffold(
      title: l10n.wrongAnswers,
      body: Center(
        child: Text(l10n.wrongAnswersComingSoon),
      ),
    );
  }
}
