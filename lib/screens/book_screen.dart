import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../data/prompts.dart';
import '../data/providers.dart';
import '../data/repository.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import '../widgets/cover.dart';
import '../widgets/dashed_rule.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_panel.dart';

/// Cover, status, progress, past reflections. Marking finished or abandoned
/// goes straight into Reflect. Not a button the user has to find.
class BookScreen extends ConsumerWidget {
  const BookScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(sessionProvider(sessionId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book'),
        actions: [
          IconButton(
            tooltip: 'Remove from shelf',
            icon: const Icon(Icons.delete_outline, color: Tokens.dim),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('$e', style: body())),
        data: (d) => d == null
            ? Center(
                child: Text('This book is no longer on your shelf.',
                    style: body(color: Tokens.dim)))
            : _BookBody(detail: d),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove this book?', style: pix(size: 20)),
        content: Text('Its reflections go with it. There is no undo.',
            style: body(size: 16, color: Tokens.dim)),
        actions: [
          QuietButton(label: 'Keep', onPressed: () => Navigator.pop(ctx, false)),
          PixelButton(
              label: 'Remove',
              tone: PixelButtonTone.surface,
              onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(repositoryProvider).deleteSession(sessionId);
      if (context.mounted) context.pop();
    }
  }
}

class _BookBody extends ConsumerWidget {
  const _BookBody({required this.detail});
  final SessionDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = detail.session;
    final b = detail.book;
    final repo = ref.read(repositoryProvider);

    Future<void> setStatus(SessionStatus status) async {
      if (status == s.status) return;
      await repo.setStatus(s.id, status);
      if (status != SessionStatus.reading && context.mounted) {
        context.push('/book/${s.id}/reflect');
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              bookId: b.id,
              title: b.title,
              author: b.author,
              coverUrl: b.coverRef,
              width: 96,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.title, style: pix(size: 24, weight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(b.author, style: body(size: 16, color: Tokens.dim)),
                  if (b.year != null)
                    Text('${b.year}', style: body(size: 14, color: Tokens.dim)),
                ],
              ),
            ),
          ],
        ),
        const DashedRule(margin: EdgeInsets.symmetric(vertical: 24)),
        Text('STATUS', style: pix(size: 13, color: Tokens.rose)),
        const SizedBox(height: 10),
        _StatusRow(current: s.status, onChanged: setStatus),
        if (s.status == SessionStatus.reading) ...[
          const SizedBox(height: 26),
          Text('HOW FAR IN', style: pix(size: 13, color: Tokens.rose)),
          _ProgressSlider(
            value: s.progress,
            onChanged: (v) => repo.setProgress(s.id, v),
          ),
        ],
        if (s.status != SessionStatus.reading) ...[
          const DashedRule(margin: EdgeInsets.symmetric(vertical: 24)),
          Text('REFLECTIONS', style: pix(size: 13, color: Tokens.rose)),
          const SizedBox(height: 12),
          if (detail.reflections.isEmpty)
            _NoReflections(sessionId: s.id)
          else ...[
            for (final r in detail.reflections) ...[
              _ReflectionTile(reflection: r),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (detail.byKey('who') != null)
                  Expanded(
                    child: PixelButton(
                      label: 'Send a card',
                      tone: PixelButtonTone.amber,
                      onPressed: () => context.push('/book/${s.id}/card'),
                    ),
                  ),
                if (detail.byKey('who') != null) const SizedBox(width: 12),
                QuietButton(
                  label: 'Edit answers',
                  onPressed: () => context.push('/book/${s.id}/reflect'),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.current, required this.onChanged});
  final SessionStatus current;
  final ValueChanged<SessionStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(SessionStatus status, String label) {
      final active = status == current;
      final color = switch (status) {
        SessionStatus.reading => Tokens.amber,
        SessionStatus.finished => Tokens.sage,
        SessionStatus.abandoned => Tokens.surfaceAlt,
      };
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(status),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? color : Tokens.surface,
              border: Border.all(color: Tokens.outline, width: 3),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: pix(
                size: 14,
                color: active && status != SessionStatus.abandoned
                    ? Tokens.inkOnCream
                    : Tokens.cream,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(SessionStatus.reading, 'Reading'),
        const SizedBox(width: 8),
        chip(SessionStatus.finished, 'Finished'),
        const SizedBox(width: 8),
        chip(SessionStatus.abandoned, 'Put down'),
      ],
    );
  }
}

class _ProgressSlider extends StatefulWidget {
  const _ProgressSlider({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<_ProgressSlider> {
  late double _v = widget.value.toDouble();

  @override
  void didUpdateWidget(covariant _ProgressSlider old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _v = widget.value.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _v,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (v) => setState(() => _v = v),
            onChangeEnd: (v) => widget.onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text('${_v.round()}%',
              textAlign: TextAlign.right, style: pix(size: 16)),
        ),
      ],
    );
  }
}

class _NoReflections extends StatelessWidget {
  const _NoReflections({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nothing written yet.', style: body(size: 16)),
          const SizedBox(height: 4),
          Text('Three questions, under two minutes, all skippable.',
              style: body(size: 14.5, color: Tokens.dim)),
          const SizedBox(height: 14),
          PixelButton(
            label: 'Answer them',
            onPressed: () => context.push('/book/$sessionId/reflect'),
          ),
        ],
      ),
    );
  }
}

class _ReflectionTile extends StatelessWidget {
  const _ReflectionTile({required this.reflection});
  final Reflection reflection;

  @override
  Widget build(BuildContext context) {
    final prompt = promptsByKey[reflection.promptKey];
    return PixelPanel(
      shadow: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prompt?.title.toUpperCase() ?? reflection.promptKey.toUpperCase(),
              style: pix(size: 12, color: Tokens.rose)),
          const SizedBox(height: 6),
          Text(reflection.response, style: body(size: 16)),
        ],
      ),
    );
  }
}
