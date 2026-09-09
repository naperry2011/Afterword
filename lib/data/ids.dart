import 'dart:math';

final _rng = Random.secure();
const _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';

/// Compact random id. Not sortable on purpose; ordering comes from timestamps.
String newId([int length = 16]) =>
    List.generate(length, (_) => _alphabet[_rng.nextInt(_alphabet.length)])
        .join();
