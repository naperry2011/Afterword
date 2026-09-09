import 'database.dart';

/// Reflection prompts. Stored by key, never by index or wording, so copy can
/// change in an update without touching stored answers.
class Prompt {
  const Prompt({
    required this.key,
    required this.title,
    required this.example,
    this.optional = false,
  });

  final String key;
  final String title;

  /// One-line example under every prompt so the field is never a blank page.
  final String example;

  /// Visually lighter, still skippable like the rest.
  final bool optional;
}

const Prompt promptStayed = Prompt(
  key: 'stayed',
  title: 'What stayed with you?',
  example: 'Not a summary. The image or line still sitting there a day later.',
);

const Prompt promptWho = Prompt(
  key: 'who',
  title: 'Who should read this, and why them?',
  example: 'Naming one person turns a review into a recommendation.',
);

const Prompt promptChanged = Prompt(
  key: 'changed',
  title: 'What did it change?',
  example: 'Often the honest answer is nothing.',
  optional: true,
);

const Prompt promptStopped = Prompt(
  key: 'stopped',
  title: 'Where did you stop, and why?',
  example: 'Page, chapter, or just the moment you knew.',
);

const Map<String, Prompt> promptsByKey = {
  'stayed': promptStayed,
  'who': promptWho,
  'changed': promptChanged,
  'stopped': promptStopped,
};

/// The finishing flow. The abandon variant swaps the first prompt.
List<Prompt> promptsFor(SessionStatus status) => switch (status) {
      SessionStatus.abandoned => const [promptStopped, promptWho, promptChanged],
      _ => const [promptStayed, promptWho, promptChanged],
    };
