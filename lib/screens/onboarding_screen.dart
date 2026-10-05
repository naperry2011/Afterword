import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../theme/layout.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import '../widgets/onboarding_art.dart';
import '../widgets/pixel_button.dart';

/// Three screens, no more. Copy is a first pass; polish on Sept 10.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.initialPage = 0});
  final int initialPage;

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
  late int _index = widget.initialPage.clamp(0, _pages.length - 1);

  Widget _artFor(int index, Fit fit) => switch (index) {
    0 => MiniShelf(spineHeight: fit.hero(96)),
    1 => const MiniPrompts(),
    _ => const MiniCard(),
  };

  Future<void> _done() async {
    await ref.read(repositoryProvider).setMeta(onboardingSeenKey, 'true');
    ref.invalidate(onboardingSeenProvider);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final (title, text) = _pages[_index];
    final last = _index == _pages.length - 1;
    final fit = Fit.of(context);
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
              // Scrolls at large Dynamic Type instead of overflowing. Otherwise
              // the block sits a little above centre, with more room below it
              // than above, so tall screens don't leave it floating low.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(flex: 2),
                            _artFor(_index, fit),
                            SizedBox(height: fit.hero(32)),
                            Text(
                              title,
                              style: pix(size: 32, weight: FontWeight.w600),
                            ),
                            SizedBox(height: fit.hero(14)),
                            Text(
                              text,
                              style: body(size: 17.5, color: Tokens.dim),
                            ),
                            const SizedBox(height: 24),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              PixelButton(
                label: last ? 'Start tonight' : 'Next',
                expand: true,
                onPressed: () => last ? _done() : setState(() => _index++),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
