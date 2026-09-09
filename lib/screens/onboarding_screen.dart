import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import '../widgets/dither_fill.dart';
import '../widgets/pixel_button.dart';

/// Three screens, no more. Copy is a first pass; polish on Sept 10.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

const _pages = [
  (
    'Read one more book than last year',
    'Afterword gives you something small and good to do when you finish a book, so there\'s a reason to finish the next one.',
  ),
  (
    'Three questions when you close it',
    'What stayed with you. Who should read it. What it changed. All skippable, none of them a blank page.',
  ),
  (
    'Yours and nobody else\'s',
    'Your shelf and everything you write stay on this phone. The only thing that leaves is a card you choose to send.',
  ),
];

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _index = 0;

  Future<void> _done() async {
    await ref.read(repositoryProvider).setMeta(onboardingSeenKey, 'true');
    ref.invalidate(onboardingSeenProvider);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final (title, text) = _pages[_index];
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < _pages.length; i++) ...[
                    Container(
                      width: 22,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index ? Tokens.amber : Tokens.surfaceAlt,
                        border: Border.all(color: Tokens.outline, width: 2),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const Spacer(),
                  QuietButton(label: 'Skip', onPressed: _done),
                ],
              ),
              const Spacer(),
              const SizedBox(width: 72, height: 108, child: DitherFill()),
              const SizedBox(height: 28),
              Text(title, style: pix(size: 32, weight: FontWeight.w600)),
              const SizedBox(height: 14),
              Text(text, style: body(size: 17.5, color: Tokens.dim)),
              const Spacer(flex: 2),
              PixelButton(
                label: last ? 'Start tonight' : 'Next',
                expand: true,
                onPressed: () =>
                    last ? _done() : setState(() => _index++),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
