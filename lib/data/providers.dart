import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'open_library.dart';
import 'repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider =
    Provider<Repository>((ref) => Repository(ref.watch(databaseProvider)));

final openLibraryProvider = Provider<OpenLibrary>((ref) => OpenLibrary());

final shelfProvider = StreamProvider<List<ShelfEntry>>(
    (ref) => ref.watch(repositoryProvider).watchShelf());

final sessionProvider = StreamProvider.family<SessionDetail?, String>(
    (ref, id) => ref.watch(repositoryProvider).watchSession(id));

const onboardingSeenKey = 'onboarding.seen';

final onboardingSeenProvider = FutureProvider<bool>((ref) async {
  final v = await ref.watch(repositoryProvider).getMeta(onboardingSeenKey);
  return v == 'true';
});
