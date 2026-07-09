import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A GenUI surface offering to start an isolated session for a different
/// hobby the user mentioned mid-conversation.
///
/// Tapping the CTA dispatches a [UserActionEvent] named
/// `startNewSessionSelected` carrying [hobbyName]. `HobbyConversation`
/// filters it onto its `newSessionRequests` stream instead of sending it
/// to the agent.
class StartNewSession extends StatelessWidget {
  /// Creates a [StartNewSession].
  const StartNewSession({
    required this.itemContext,
    required this.message,
    required this.hobbyName,
    this.ctaLabel,
    super.key,
  });

  /// The GenUI item context used to dispatch the pivot action.
  final CatalogItemContext itemContext;

  /// The agent's message inviting the pivot, e.g. "Want to put rock
  /// climbing aside and explore beekeeping instead?"
  final String message;

  /// The hobby name to seed the new session with.
  final String hobbyName;

  /// Optional CTA label. Defaults to "Start $hobbyName instead".
  final String? ctaLabel;

  void _onSelect() {
    itemContext.dispatchEvent(
      UserActionEvent(
        name: 'startNewSessionSelected',
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
      color: HobItColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HobItSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HobItSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: textTheme.bodyMedium),
            const SizedBox(height: HobItSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _onSelect,
                child: Text(ctaLabel ?? 'Start $hobbyName instead'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}