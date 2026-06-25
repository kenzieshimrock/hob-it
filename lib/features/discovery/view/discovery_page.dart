import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hob_it/features/discovery/bloc/discovery_bloc.dart';

/// The entry point for the Discovery flow.
///
/// Provides [DiscoveryBloc] to the widget subtree and delegates
/// rendering to [DiscoveryView].
class DiscoveryPage extends StatelessWidget {
  /// Creates an [DiscoveryPage].
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoveryBloc(),
      child: const DiscoveryView(),
    );
  }
}

/// The visual layer of the Discovery flow.
///
/// Renders the hobby input field and submit button, and reacts
/// to [DiscoveryState] changes emitted by [DiscoveryBloc].
class DiscoveryView extends StatelessWidget {
  /// Creates a [DiscoveryView].
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiscoveryBloc, DiscoveryState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == DiscoveryStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something went wrong. Try again.')),
          );
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(),
                SizedBox(height: 40),
                _HobbyInputField(),
                SizedBox(height: 24),
                _SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the hob-it title and prompt text.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'hob-it',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('What hobby do you want to explore?'),
      ],
    );
  }
}

/// Text field that dispatches [DiscoveryHobbyInputChanged] on every keystroke.
class _HobbyInputField extends StatelessWidget {
  const _HobbyInputField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'e.g. I want to try fly fishing',
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) =>
          context.read<DiscoveryBloc>().add(DiscoveryHobbyInputChanged(value)),
    );
  }
}

/// Submit button that dispatches [DiscoverySubmitted].
///
/// Displays a loading indicator while [DiscoveryStatus.loading] is active.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final status = context.select((DiscoveryBloc bloc) => bloc.state.status);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: status == DiscoveryStatus.loading
            ? null
            : () =>
                  context.read<DiscoveryBloc>().add(const DiscoverySubmitted()),
        child: status == DiscoveryStatus.loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Let's go"),
      ),
    );
  }
}
