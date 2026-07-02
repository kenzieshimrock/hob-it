import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A single selectable option within a [ClarifyingCard].
class ClarifyingOption {
  /// Creates a [ClarifyingOption].
  const ClarifyingOption({required this.label, required this.value});

  /// The text shown to the user.
  final String label;

  /// The machine-readable value sent back to the agent on submission.
  final String value;
}

/// A GenUI card that presents a clarifying question.
///
/// The selected option is bound to this surface's DataModel at the relative
/// `selected` path, so the choice survives the widget being disposed and
/// rebuilt, for example when scrolled out of the feed. On Continue it
/// dispatches a [UserActionEvent] named `clarifyingOptionsSelected`.
class ClarifyingCard extends StatelessWidget {
  /// Creates a [ClarifyingCard].
  const ClarifyingCard({
    required this.itemContext,
    required this.title,
    required this.options,
    this.subtitle,
    super.key,
  });

  /// The GenUI item context used to dispatch events and reach the DataModel.
  final CatalogItemContext itemContext;

  /// The clarifying question shown at the top of the card.
  final String title;

  /// Optional supporting context displayed below [title].
  final String? subtitle;

  /// The answer options the user can choose from.
  final List<ClarifyingOption> options;

  void _submit(String value) {
    itemContext.dispatchEvent(
      UserActionEvent(
        name: 'clarifyingOptionsSelected',
        sourceComponentId: itemContext.id,
        context: {'value': value},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataContext = itemContext.dataContext;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HobItSpacing.lg),
        child: BoundString(
          dataContext: dataContext,
          value: const {'path': 'selected'},
          builder: (context, selected) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CLARIFYING', style: HobItTypography.agentLabel),
                const SizedBox(height: HobItSpacing.sm),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: HobItSpacing.xs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HobItColors.navy.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: HobItSpacing.md),
                ...options.map(
                  (option) => _OptionTile(
                    option: option,
                    isSelected: selected == option.value,
                    onTap: () =>
                        dataContext.update(DataPath('selected'), option.value),
                  ),
                ),
                const SizedBox(height: HobItSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: selected != null
                        ? () => _submit(selected)
                        : null,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A single selectable option tile inside [ClarifyingCard].
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final ClarifyingOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HobItSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HobItSpacing.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: HobItSpacing.md,
            vertical: HobItSpacing.smd,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? HobItColors.blue.withValues(alpha: 0.08)
                : HobItColors.iconTile,
            border: Border.all(
              color: isSelected
                  ? HobItColors.blue
                  : HobItColors.navy.withValues(alpha: 0.15),
              width: isSelected ? 1.5 : 0.75,
            ),
            borderRadius: BorderRadius.circular(HobItSpacing.radiusSm),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? HobItColors.blue : HobItColors.navy,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: HobItColors.blue,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
