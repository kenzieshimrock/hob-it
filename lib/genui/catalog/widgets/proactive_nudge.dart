import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A GenUI home surface nudging the user to follow up on a past session.
///
/// Tapping the action dispatches a [UserActionEvent] named
/// `proactiveNudgeSelected`; the home layer routes it to Discover.
class ProactiveNudge extends StatelessWidget {
  /// Creates a [ProactiveNudge].
  const ProactiveNudge({
    required this.itemContext,
    required this.message,
    this.contextSummary,
    this.actionLabel,
    super.key,
  });

  /// The GenUI item context used to dispatch the navigation action.
  final CatalogItemContext itemContext;

  /// The nudge message.
  final String message;

  /// Optional short context line shown below the message.
  final String? contextSummary;

  /// Optional action button label.
  final String? actionLabel;

  void _onAction() {
    itemContext.dispatchEvent(
      UserActionEvent(
        name: 'proactiveNudgeSelected',
        sourceComponentId: itemContext.id,
        context: {'message': message},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: HobItColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HobItSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HobItSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HobItColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: HobItColors.amber,
              ),
            ),
            const SizedBox(width: HobItSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: textTheme.bodyMedium),
                  if (contextSummary != null) ...[
                    const SizedBox(height: HobItSpacing.xs),
                    Text(
                      contextSummary!,
                      style: textTheme.bodySmall?.copyWith(
                        color: HobItColors.navy40,
                      ),
                    ),
                  ],
                  if (actionLabel != null) ...[
                    const SizedBox(height: HobItSpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: HobItColors.blue,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(actionLabel!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
