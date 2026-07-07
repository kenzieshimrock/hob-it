import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A GenUI home surface that resurfaces a hobby from the user's memory.
///
/// Shows a branded hero with the hobby name, why it's suggested now, and a
/// call to action. Tapping the CTA dispatches a [UserActionEvent] named
/// `recommendedHobbySelected` carrying [hobbyName]; the home layer routes it
/// to the Discover tab rather than sending it to the agent.
class RecommendedHobby extends StatelessWidget {
  /// Creates a [RecommendedHobby].
  const RecommendedHobby({
    required this.itemContext,
    required this.hobbyName,
    required this.reason,
    this.lastMentioned,
    this.ctaLabel,
    super.key,
  });

  /// The GenUI item context used to dispatch the navigation action.
  final CatalogItemContext itemContext;

  /// The hobby to resurface.
  final String hobbyName;

  /// One sentence on why it's being suggested now.
  final String reason;

  /// Optional note on when it last came up.
  final String? lastMentioned;

  /// Optional CTA label. Defaults to "Pick it back up".
  final String? ctaLabel;

  void _onSelect() {
    itemContext.dispatchEvent(
      UserActionEvent(
        name: 'recommendedHobbySelected',
        sourceComponentId: itemContext.id,
        context: {'hobbyName': hobbyName},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: HobItColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HobItSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HobItSpacing.md),
            decoration: const BoxDecoration(
              gradient: HobItColors.brandGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PICK UP WHERE YOU LEFT OFF',
                  style: HobItTypography.agentLabel.copyWith(
                    color: HobItColors.white,
                  ),
                ),
                const SizedBox(height: HobItSpacing.xs),
                Text(
                  hobbyName,
                  style: textTheme.headlineSmall?.copyWith(
                    color: HobItColors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(HobItSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reason, style: textTheme.bodyMedium),
                if (lastMentioned != null) ...[
                  const SizedBox(height: HobItSpacing.xs),
                  Text(
                    lastMentioned!,
                    style: textTheme.bodySmall?.copyWith(
                      color: HobItColors.navy40,
                    ),
                  ),
                ],
                const SizedBox(height: HobItSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onSelect,
                    child: Text(ctaLabel ?? 'Pick it back up'),
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
