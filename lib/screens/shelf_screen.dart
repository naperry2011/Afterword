import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../data/repository.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import '../widgets/dashed_rule.dart';
import '../widgets/pixel_button.dart';
import '../widgets/spine.dart';

/// The home screen. Spines, then the empty slot. The empty slot is the pull.
class ShelfScreen extends ConsumerWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelf = ref.watch(shelfProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Afterword'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune, color: Tokens.dim),
          ),
        ],
      ),
      body: shelf.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(
            child: Text('Shelf failed to load.\n$e',
                textAlign: TextAlign.center, style: body(color: Tokens.dim))),
        data: (entries) => _ShelfBody(entries: entries),
      ),
    );
  }
}

class _ShelfBody extends StatelessWidget {
  const _ShelfBody({required this.entries});
  final List<ShelfEntry> entries;

  @override
  Widget build(BuildContext context) {
    final finished =
        entries.where((e) => e.session.status == SessionStatus.finished).toList();
    final reading =
        entries.where((e) => e.session.status == SessionStatus.reading).toList();
    final abandoned = entries
        .where((e) => e.session.status == SessionStatus.abandoned)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 40),
      children: [
        _ShelfRow(finished: finished, reading: reading, abandoned: abandoned),
        const SizedBox(height: 14),
        Center(
          child: Text(
            _countLine(finished.length, reading.length),
            style: pix(size: 13.5, color: Tokens.dim),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PixelButton(
            label: entries.isEmpty ? 'Add the book you\'re reading' : 'Add a book',
            expand: true,
            onPressed: () => context.push('/add'),
          ),
        ),
        if (entries.isEmpty) ...[
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add whatever you\'re already in the middle of and your shelf has begun.',
              textAlign: TextAlign.center,
              style: body(size: 16, color: Tokens.dim),
            ),
          ),
        ] else ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: DashedRule(margin: EdgeInsets.symmetric(vertical: 28)),
          ),
          for (final e in [...reading, ...finished, ...abandoned])
            _ShelfListTile(entry: e),
        ],
      ],
    );
  }

  String _countLine(int finished, int reading) {
    final parts = <String>[
      '${_word(finished)} FINISHED',
      if (reading > 0) '${_word(reading)} IN PROGRESS',
      'ONE WAITING',
    ];
    return parts.join(' · ');
  }
}

const _words = [
  'NO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE',
  'TEN', 'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN', 'SIXTEEN',
  'SEVENTEEN', 'EIGHTEEN', 'NINETEEN', 'TWENTY',
];

String _word(int n) => n >= 0 && n < _words.length ? _words[n] : '$n';

/// Horizontal row of spines on a dark ground, amber warmth at one edge as a
/// flat band. Finished solid, reading outlined and partly filled, next dithered.
class _ShelfRow extends StatelessWidget {
  const _ShelfRow({
    required this.finished,
    required this.reading,
    required this.abandoned,
  });
  final List<ShelfEntry> finished;
  final List<ShelfEntry> reading;
  final List<ShelfEntry> abandoned;

  static const double _maxHeight = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _maxHeight + 40,
      child: Stack(
        children: [
          // Flat lamp warmth, no gradient (spec §2.5).
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 64,
            child: Container(color: Tokens.amber.withValues(alpha: 0.10)),
          ),
          // The shelf plank.
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
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
          Positioned.fill(
            bottom: 26,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                for (final e in finished.reversed) ...[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () => context.push('/book/${e.session.id}'),
                      child: SolidSpine(
                          bookId: e.book.id, maxHeight: _maxHeight),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                for (final e in abandoned.reversed) ...[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () => context.push('/book/${e.session.id}'),
                      child: Opacity(
                        opacity: 0.55,
                        child: SolidSpine(
                            bookId: e.book.id, maxHeight: _maxHeight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                for (final e in reading) ...[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () => context.push('/book/${e.session.id}'),
                      child: ProgressSpine(
                        bookId: e.book.id,
                        maxHeight: _maxHeight,
                        progress: e.session.progress,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () => context.push('/add'),
                    child: const EmptySlot(maxHeight: _maxHeight),
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

class _ShelfListTile extends StatelessWidget {
  const _ShelfListTile({required this.entry});
  final ShelfEntry entry;

  @override
  Widget build(BuildContext context) {
    final s = entry.session;
    final label = switch (s.status) {
      SessionStatus.reading => '${s.progress}% IN',
      SessionStatus.finished => 'FINISHED',
      SessionStatus.abandoned => 'PUT DOWN',
    };
    final labelColor = switch (s.status) {
      SessionStatus.reading => Tokens.amber,
      SessionStatus.finished => Tokens.sage,
      SessionStatus.abandoned => Tokens.dim,
    };
    return InkWell(
      onTap: () => context.push('/book/${s.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 36,
              decoration: BoxDecoration(
                color: spineColorFor(entry.book.id),
                border: Border.all(color: Tokens.outline, width: 2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: body(size: 16.5, weight: FontWeight.w600)),
                  Text(entry.book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: body(size: 14, color: Tokens.dim)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(label, style: pix(size: 12, color: labelColor)),
          ],
        ),
      ),
    );
  }
}
