import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/providers.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';
import '../widgets/dashed_rule.dart';
import '../widgets/pixel_button.dart';

/// Export, import, about, privacy. Nothing leaves the device unless you send it.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  void _say(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final json = await ref.read(repositoryProvider).exportJson();
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().toIso8601String().split('T').first;
      final file = File('${dir.path}/afterword-export-$stamp.json');
      await file.writeAsString(json);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Afterword export',
      ));
    } catch (e) {
      _say('Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      final f = picked.firstOrNull;
      if (f == null) return;
      final bytes = await f.readAsBytes();
      final count =
          await ref.read(repositoryProvider).importJson(utf8.decode(bytes));
      _say('Imported $count ${count == 1 ? 'book' : 'books'}.');
    } on FormatException catch (e) {
      _say(e.message);
    } catch (e) {
      _say('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: [
          Text('YOUR DATA', style: pix(size: 13, color: Tokens.rose)),
          const SizedBox(height: 8),
          Text(
            'Everything lives on this phone. Export a copy before you switch devices, and import it on the new one.',
            style: body(size: 15.5, color: Tokens.dim),
          ),
          const SizedBox(height: 16),
          PixelButton(
              label: 'Export as JSON', expand: true, onPressed: _busy ? null : _export),
          const SizedBox(height: 10),
          PixelButton(
            label: 'Import from JSON',
            tone: PixelButtonTone.surface,
            expand: true,
            onPressed: _busy ? null : _import,
          ),
          const DashedRule(margin: EdgeInsets.symmetric(vertical: 28)),
          Text('PRIVACY', style: pix(size: 13, color: Tokens.rose)),
          const SizedBox(height: 8),
          Text(
            'No account. No server. No analytics. The only network request is searching Open Library for a title, and the only thing that leaves the device is a card you choose to send.',
            style: body(size: 15.5, color: Tokens.dim),
          ),
          const DashedRule(margin: EdgeInsets.symmetric(vertical: 28)),
          Text('ABOUT', style: pix(size: 13, color: Tokens.rose)),
          const SizedBox(height: 8),
          Text('Afterword 1.0', style: body(size: 16)),
          Text('A small, good thing to do when you finish a book.',
              style: body(size: 15.5, color: Tokens.dim)),
          const SizedBox(height: 6),
          Text('Book data from Open Library. Type set in Pixelify Sans and Nunito.',
              style: body(size: 13.5, color: Tokens.dim)),
        ],
      ),
    );
  }
}
