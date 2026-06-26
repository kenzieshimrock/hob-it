import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A single selectable option within a [ClarifyingCardWidget].
class ClarifyingOption {
  const ClarifyingOption({required this.label, required this.value});

  /// The text shown to the user.
  final String label;

  /// The machine-readable value sent back to the agent on submission.
  final String value;
}

/// A GenUI-rendered card that presents a clarifying question.
///
/// Renders a question with selectable option tiles. When the user selects
/// an option and taps Continue, dispatches a [UserActionEvent] named
/// `clarifyingOptionsSelected` carrying the selected [ClarifyingOption.value]
class ClarifyingCardWidget extends StatefulWidget {
  /// Creates a [ClarifyingCardWidget].
  const ClarifyingCardWidget({
    super.key,
    required this.itemContext,
    required this.title,
    this.subtitle,
    required this.options,
  });

  /// The GenUI item context used to dispatch selection events to the agent.
  final CatalogItemContext itemContext;

  /// The clarifying question shown at the top of the card.
  final String title;

  /// Optional supporting context displayed below [title]
  final String? subtitle;

  /// The answer options the user can choose form.
  final List<ClarifyingOption> options;

  @override
  State<ClarifyingCardWidget> createState() => _ClarifyingCardWidgetState();
}

class _ClarifyingCardWidgetState extends State<ClarifyingCardWidget> {
  String? _selectedValue;

  void _onSelect(String value) {
    setState(() {
      _selectedValue = value;
    });
  }

  void _onSubmit() {
    if (_selectedValue == null) return;
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        name: 'clarifyingOptionsSelected',
        sourceComponentId: widget.itemContext.id,
        context: {'value': _selectedValue},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HobItSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CLARIFYING', style: HobItTypography.agentLabel),
            const SizedBox(height: HobItSpacing.sm),
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            if (widget.subtitle != null) ...[
              const SizedBox(height: HobItSpacing.xs),
              Text(
                widget.subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HobItColors.navy.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: HobItSpacing.md),
            ...widget.options.map(
              (option) => _OptionTile(
                option: option,
                isSelected: _selectedValue == option.value,
                onTap: () => _onSelect(option.value),
              ),
            ),
            const SizedBox(height: HobItSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedValue != null ? _onSubmit : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single selectable option tile inside [ClarifyingCardWidget].
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
