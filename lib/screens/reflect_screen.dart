import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../data/prompts.dart';
import '../data/providers.dart';
import '../data/repository.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import '../widgets/pixel_button.dart';

/// The flow that decides whether this app deserves to exist.
/// One prompt per screen, sequential, large type, cream on dark.
/// Skip is always visible and never discouraged.
class ReflectScreen extends ConsumerStatefulWidget {
  const ReflectScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  ConsumerState<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends ConsumerState<ReflectScreen> {
  int _index = 0;
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  TextEditingController _controllerFor(String key, String initial) =>
      _controllers.putIfAbsent(key, () => TextEditingController(text: initial));

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _finish(SessionDetail detail, List<Prompt> prompts) async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    final responses = {
      for (final p in prompts) p.key: _controllers[p.key]?.text ?? '',
    };
    await repo.saveReflections(detail.session.id, responses);
    if (detail.session.status == SessionStatus.abandoned) {
      final stopped = responses['stopped']?.trim();
      await repo.setAbandonReason(
          detail.session.id, stopped == null || stopped.isEmpty ? null : stopped);
    }
    if (!mounted) return;
    final who = responses['who']?.trim() ?? '';
    if (who.isNotEmpty) {
      context.pushReplacement('/book/${detail.session.id}/card');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(sessionProvider(widget.sessionId));
    return Scaffold(
      body: SafeArea(
        child: detail.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Center(child: Text('$e', style: body())),
          data: (d) {
            if (d == null) return const SizedBox.shrink();
            final prompts = promptsFor(d.session.status);
            final prompt = prompts[_index];
            final last = _index == prompts.length - 1;
            final controller =
                _controllerFor(prompt.key, d.byKey(prompt.key)?.response ?? '');
            final titleColor = prompt.optional ? Tokens.dim : Tokens.cream;

            return Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_index + 1} OF ${prompts.length}'
                        '${prompt.optional ? ' · OPTIONAL' : ''}',
                        style: pix(size: 13, color: Tokens.rose),
                      ),
                      const Spacer(),
                      QuietButton(
                        label: 'Close',
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    d.book.title,
                    style: body(size: 15, color: Tokens.dim),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    prompt.title,
                    style: pix(
                      size: 30,
                      weight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: TextField(
                      key: ValueKey(prompt.key),
                      controller: controller,
                      autofocus: true,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: body(size: 18),
                      decoration: const InputDecoration(hintText: ''),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(prompt.example,
                      style: body(size: 15, color: Tokens.dim,
                          style: FontStyle.italic)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      QuietButton(
                        label: 'Skip',
                        onPressed: _saving
                            ? null
                            : () {
                                controller.clear();
                                if (last) {
                                  _finish(d, prompts);
                                } else {
                                  setState(() => _index++);
                                }
                              },
                      ),
                      const Spacer(),
                      PixelButton(
                        label: last ? 'Done' : 'Next',
                        onPressed: _saving
                            ? null
                            : () {
                                if (last) {
                                  _finish(d, prompts);
                                } else {
                                  setState(() => _index++);
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
