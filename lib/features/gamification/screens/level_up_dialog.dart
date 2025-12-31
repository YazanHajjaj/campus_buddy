import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

class LevelUpDialog extends StatelessWidget {
  final String levelName;
  final int gainedXp;

  const LevelUpDialog({
    super.key,
    required this.levelName,
    required this.gainedXp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎉 ICON
            CircleAvatar(
              radius: 36,
              backgroundColor: colors.primary.withOpacity(0.12),
              child: Icon(
                Icons.emoji_events,
                size: 36,
                color: colors.primary,
              ),
            ),

            const SizedBox(height: 16),

            // TITLE
            Text(
              t.t('gamification.levelUp'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            // LEVEL NAME (STRING INTERPOLATION ✅)
            Text(
              '${t.t('gamification.levelReached')} $levelName',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 6),

            // XP
            Text(
              '+$gainedXp ${t.t('gamification.xp')}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  t.t('common.awesome'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}