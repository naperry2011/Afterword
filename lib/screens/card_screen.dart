import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/providers.dart';
import '../data/repository.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import '../widgets/cover.dart';
import '../widgets/dashed_rule.dart';
import '../widgets/pixel_button.dart';

/// Fixed logical card size. Captured at 2x for a 1080x1350 PNG on any device.
const Size kCardSize = Size(540, 675);
const double kCardPixelRatio = 2;

/// Renders the answer to `who` over the cover and title, then straight to the
/// system share sheet. No server, no headless renderer.
class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  final GlobalKey _boundary = GlobalKey();
  bool _sharing = false;

  Future<void> _share(SessionDetail d) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _boundary.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: kCardPixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final safe = d.book.title
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');
      final file = File('${dir.path}/afterword-$safe.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await ref.read(repositoryProvider).recordCard(
            d.session.id,
            d.reflections.map((r) => r.id).toList(),
          );
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: 'You should read ${d.book.title}',
      ));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(sessionProvider(widget.sessionId));
    return Scaffold(
      appBar: AppBar(title: const Text('Card')),
      body: detail.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('$e', style: body())),
        data: (d) {
          if (d == null) return const SizedBox.shrink();
          final who = d.byKey('who');
          if (who == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('No card yet.',
                        style: pix(size: 22, weight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      'The card is your answer to "Who should read this, and why them?"',
                      textAlign: TextAlign.center,
                      style: body(size: 16, color: Tokens.dim),
                    ),
                    const SizedBox(height: 22),
                    PixelButton(
                      label: 'Answer it',
                      onPressed: () => context
                          .pushReplacement('/book/${d.session.id}/reflect'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FittedBox(
                      child: RepaintBoundary(
                        key: _boundary,
                        child: _RecommendationCard(detail: d, who: who.response),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: PixelButton(
                  label: _sharing ? 'Rendering…' : 'Send it',
                  tone: PixelButtonTone.amber,
                  expand: true,
                  onPressed: _sharing ? null : () => _share(d),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.detail, required this.who});
  final SessionDetail detail;
  final String who;

  @override
  Widget build(BuildContext context) {
    final b = detail.book;
    return SizedBox(
      width: kCardSize.width,
      height: kCardSize.height,
      child: Container(
        // The room around the card, so the PNG has its own ground.
        color: Tokens.bg,
        padding: const EdgeInsets.all(40),
        child: Container(
          decoration: BoxDecoration(
            color: Tokens.cream,
            border: Border.all(color: Tokens.outline, width: 4),
            boxShadow: const [
              BoxShadow(color: Tokens.amber, offset: Offset(8, 8), blurRadius: 0),
            ],
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BookCover(
                    bookId: b.id,
                    title: b.title,
                    author: b.author,
                    coverUrl: b.coverRef,
                    width: 72,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pix(
                                size: 26,
                                weight: FontWeight.w600,
                                color: Tokens.inkOnCream)),
                        const SizedBox(height: 4),
                        Text(b.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: body(size: 16, color: Tokens.dimOnCream)),
                      ],
                    ),
                  ),
                ],
              ),
              const DashedRule(
                  color: Tokens.ruleOnCream,
                  margin: EdgeInsets.symmetric(vertical: 18)),
              Expanded(
                child: Text(
                  who,
                  maxLines: 9,
                  overflow: TextOverflow.ellipsis,
                  style: body(size: 21, color: Tokens.inkOnCream)
                      .copyWith(height: 1.55),
                ),
              ),
              const DashedRule(
                  color: Tokens.ruleOnCream,
                  margin: EdgeInsets.only(top: 14, bottom: 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('A RECOMMENDATION',
                      style: pix(size: 14, color: Tokens.dimOnCream)),
                  Text('AFTERWORD',
                      style: pix(size: 14, color: Tokens.dimOnCream)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
