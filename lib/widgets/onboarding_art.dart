import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/prompts.dart';
import '../theme/shapes.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import 'dashed_rule.dart';
import 'spine.dart';

/// Illustrations for the three onboarding pages, built from the app's own
/// widgets so the first thing a person sees is the thing they will use.

/// A short shelf: three finished spines, one in progress, one waiting.
class MiniShelf extends StatelessWidget {
  const MiniShelf({super.key});

  static const double _h = 96;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _h + 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 48,
            child: Container(color: Tokens.amber.withValues(alpha: 0.10)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Container(
              height: 8,
              decoration: const BoxDecoration(
                color: Tokens.surfaceAlt,
                border: Border(
                  top: BorderSide(color: Tokens.outline, width: 3),
                  bottom: BorderSide(color: Tokens.outline, width: 3),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                SolidSpine(bookId: 'onboarding-a', maxHeight: _h),
                SizedBox(width: 6),
                SolidSpine(bookId: 'onboarding-b', maxHeight: _h),
                SizedBox(width: 6),
                SolidSpine(bookId: 'onboarding-c', maxHeight: _h),
                SizedBox(width: 6),
                ProgressSpine(
                  bookId: 'onboarding-d',
                  maxHeight: _h,
                  progress: 55,
                ),
                SizedBox(width: 6),
                EmptySlot(maxHeight: _h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The three finishing prompts, numbered, the optional one lighter.
class MiniPrompts extends StatelessWidget {
  const MiniPrompts({super.key});

  @override
  Widget build(BuildContext context) {
    final prompts = promptsFor(SessionStatus.finished);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < prompts.length; i++) ...[
          if (i > 0)
            const DashedRule(margin: EdgeInsets.symmetric(vertical: 10)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}',
                style: pix(
                  size: 13,
                  color: prompts[i].optional ? Tokens.dim : Tokens.rose,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  prompts[i].title,
                  style: pix(
                    size: 19,
                    weight: FontWeight.w600,
                    color: prompts[i].optional ? Tokens.dim : Tokens.cream,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A small recommendation card, the way it lands in a friend's messages.
class MiniCard extends StatelessWidget {
  const MiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Tokens.cream,
        border: pixelBorder(),
        boxShadow: const [
          BoxShadow(color: Tokens.amber, offset: Offset(6, 6), blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 44,
                decoration: BoxDecoration(
                  color: Tokens.teal,
                  border: pixelBorder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Piranesi',
                      style: pix(
                        size: 17,
                        weight: FontWeight.w600,
                        color: Tokens.inkOnCream,
                      ),
                    ),
                    Text(
                      'Susanna Clarke',
                      style: body(size: 12.5, color: Tokens.dimOnCream),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const DashedRule(
            color: Tokens.ruleOnCream,
            margin: EdgeInsets.symmetric(vertical: 10),
          ),
          Text(
            'You read for atmosphere more than plot and this is nothing but atmosphere.',
            style: body(
              size: 14,
              color: Tokens.inkOnCream,
            ).copyWith(height: 1.5),
          ),
          const DashedRule(
            color: Tokens.ruleOnCream,
            margin: EdgeInsets.only(top: 10, bottom: 8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FROM A FRIEND',
                style: pix(size: 11, color: Tokens.dimOnCream),
              ),
              Text('AFTERWORD', style: pix(size: 11, color: Tokens.dimOnCream)),
            ],
          ),
        ],
      ),
    );

    // A picture of a card: fixed text scale, like the real share card. Room
    // on the right and below for the tilt and the offset shadow.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Padding(
        padding: const EdgeInsets.only(right: 12, bottom: 8),
        child: Transform.rotate(angle: -0.02, child: card),
      ),
    );
  }
}
