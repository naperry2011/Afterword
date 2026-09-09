import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../data/open_library.dart';
import '../data/providers.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import '../widgets/cover.dart';
import '../widgets/dashed_rule.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_panel.dart';

/// Open Library search with a manual fallback. Search failure is never a
/// dead end and never a spinner that doesn't resolve.
class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

enum _Phase { idle, searching, results, failed }

class _AddScreenState extends ConsumerState<AddScreen> {
  final _query = TextEditingController();
  _Phase _phase = _Phase.idle;
  List<BookHit> _hits = const [];
  String _error = '';
  bool _manual = false;
  bool _adding = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.isEmpty) return;
    setState(() => _phase = _Phase.searching);
    final result = await ref.read(openLibraryProvider).search(q);
    if (!mounted) return;
    switch (result) {
      case SearchSuccess(:final hits):
        setState(() {
          _hits = hits;
          _phase = _Phase.results;
        });
      case SearchFailure(:final message):
        setState(() {
          _error = message;
          _phase = _Phase.failed;
        });
    }
  }

  Future<void> _addHit(BookHit hit) async {
    if (_adding) return;
    setState(() => _adding = true);
    final id = await ref.read(repositoryProvider).addBook(
          title: hit.title,
          author: hit.author,
          year: hit.year,
          coverRef: hit.coverUrlLarge,
          openLibraryKey: hit.key,
          source: BookSource.api,
        );
    if (!mounted) return;
    context.pushReplacement('/book/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_manual ? 'Add by hand' : 'Add a book')),
      body: _manual
          ? _ManualEntry(
              initialTitle: _query.text,
              onCancel: () => setState(() => _manual = false),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              children: [
                TextField(
                  controller: _query,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  style: body(size: 17),
                  decoration: const InputDecoration(
                      hintText: 'Title or author'),
                ),
                const SizedBox(height: 12),
                PixelButton(
                  label: _phase == _Phase.searching ? 'Searching…' : 'Search',
                  expand: true,
                  onPressed: _phase == _Phase.searching ? null : _search,
                ),
                const SizedBox(height: 8),
                Center(
                  child: QuietButton(
                    label: 'Add it by hand instead',
                    onPressed: () => setState(() => _manual = true),
                  ),
                ),
                const DashedRule(margin: EdgeInsets.symmetric(vertical: 16)),
                ..._body(),
              ],
            ),
    );
  }

  List<Widget> _body() {
    switch (_phase) {
      case _Phase.idle:
        return [
          Text('Search Open Library, or add it by hand if it isn\'t there.',
              style: body(size: 15.5, color: Tokens.dim)),
        ];
      case _Phase.searching:
        return [
          Text('Asking Open Library…', style: body(size: 15.5, color: Tokens.dim)),
        ];
      case _Phase.failed:
        return [
          PixelPanel(
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SEARCH DIDN\'T WORK', style: pix(size: 12, color: Tokens.rose)),
                const SizedBox(height: 6),
                Text(_error, style: body(size: 16)),
                const SizedBox(height: 6),
                Text('You can still add the book. Nothing is lost.',
                    style: body(size: 14.5, color: Tokens.dim)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    PixelButton(
                        label: 'Add by hand',
                        onPressed: () => setState(() => _manual = true)),
                    const SizedBox(width: 8),
                    QuietButton(label: 'Try again', onPressed: _search),
                  ],
                ),
              ],
            ),
          ),
        ];
      case _Phase.results:
        if (_hits.isEmpty) {
          return [
            Text('Nothing matched.', style: pix(size: 18)),
            const SizedBox(height: 6),
            Text('Try a different spelling, or add it by hand.',
                style: body(size: 15, color: Tokens.dim)),
            const SizedBox(height: 14),
            PixelButton(
                label: 'Add by hand',
                onPressed: () => setState(() => _manual = true)),
          ];
        }
        return [
          for (final hit in _hits) _HitTile(hit: hit, onTap: () => _addHit(hit)),
        ];
    }
  }
}

class _HitTile extends StatelessWidget {
  const _HitTile({required this.hit, required this.onTap});
  final BookHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            BookCover(
              bookId: hit.key.isEmpty ? hit.title : hit.key,
              title: hit.title,
              author: hit.author,
              coverUrl: hit.coverUrl,
              width: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hit.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: body(size: 16.5, weight: FontWeight.w600)),
                  Text(
                    hit.year == null ? hit.author : '${hit.author} · ${hit.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: body(size: 14, color: Tokens.dim),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualEntry extends ConsumerStatefulWidget {
  const _ManualEntry({required this.initialTitle, required this.onCancel});
  final String initialTitle;
  final VoidCallback onCancel;

  @override
  ConsumerState<_ManualEntry> createState() => _ManualEntryState();
}

class _ManualEntryState extends ConsumerState<_ManualEntry> {
  late final _title = TextEditingController(text: widget.initialTitle);
  final _author = TextEditingController();
  final _year = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    final id = await ref.read(repositoryProvider).addBook(
          title: _title.text,
          author: _author.text.trim().isEmpty ? 'Unknown author' : _author.text,
          year: int.tryParse(_year.text.trim()),
          source: BookSource.manual,
        );
    if (!mounted) return;
    context.pushReplacement('/book/$id');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      children: [
        Text('TITLE', style: pix(size: 13, color: Tokens.rose)),
        const SizedBox(height: 8),
        TextField(
          controller: _title,
          autofocus: true,
          style: body(size: 17),
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        Text('AUTHOR', style: pix(size: 13, color: Tokens.rose)),
        const SizedBox(height: 8),
        TextField(
          controller: _author,
          style: body(size: 17),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 18),
        Text('YEAR (OPTIONAL)', style: pix(size: 13, color: Tokens.dim)),
        const SizedBox(height: 8),
        TextField(
          controller: _year,
          style: body(size: 17),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 26),
        PixelButton(
          label: 'Put it on the shelf',
          expand: true,
          onPressed: _title.text.trim().isEmpty || _saving ? null : _save,
        ),
        const SizedBox(height: 8),
        Center(child: QuietButton(label: 'Back to search', onPressed: widget.onCancel)),
      ],
    );
  }
}
