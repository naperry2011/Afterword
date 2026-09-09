import 'dart:convert';

import 'package:http/http.dart' as http;

/// A search hit from Open Library. Not yet a Book; the user picks one.
class BookHit {
  const BookHit({
    required this.key,
    required this.title,
    required this.author,
    this.year,
    this.coverId,
  });

  final String key;
  final String title;
  final String author;
  final int? year;
  final int? coverId;

  String? get coverUrl =>
      coverId == null ? null : OpenLibrary.coverUrl(coverId!, size: 'M');

  String? get coverUrlLarge =>
      coverId == null ? null : OpenLibrary.coverUrl(coverId!, size: 'L');
}

/// Search never throws to the UI. Failure carries a message and the UI offers
/// manual entry. No spinner that never resolves.
sealed class SearchResult {
  const SearchResult();
}

class SearchSuccess extends SearchResult {
  const SearchSuccess(this.hits);
  final List<BookHit> hits;
}

class SearchFailure extends SearchResult {
  const SearchFailure(this.message);
  final String message;
}

class OpenLibrary {
  OpenLibrary({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration timeout = Duration(seconds: 8);

  static String coverUrl(int coverId, {String size = 'M'}) =>
      'https://covers.openlibrary.org/b/id/$coverId-$size.jpg';

  Future<SearchResult> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const SearchSuccess([]);
    final uri = Uri.https('openlibrary.org', '/search.json', {
      'q': q,
      'fields': 'key,title,author_name,first_publish_year,cover_i',
      'limit': '20',
    });
    try {
      final res = await _client
          .get(uri, headers: {'User-Agent': 'Afterword/1.0'})
          .timeout(timeout);
      if (res.statusCode != 200) {
        return SearchFailure('Open Library answered ${res.statusCode}.');
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final docs = (json['docs'] as List<dynamic>? ?? const []);
      final hits = <BookHit>[];
      for (final d in docs) {
        final doc = d as Map<String, dynamic>;
        final title = doc['title'] as String?;
        if (title == null || title.isEmpty) continue;
        final authors = doc['author_name'] as List<dynamic>?;
        hits.add(BookHit(
          key: doc['key'] as String? ?? '',
          title: title,
          author: authors == null || authors.isEmpty
              ? 'Unknown author'
              : authors.first as String,
          year: doc['first_publish_year'] as int?,
          coverId: doc['cover_i'] as int?,
        ));
      }
      return SearchSuccess(hits);
    } on Exception catch (e) {
      final msg = e.toString().contains('TimeoutException')
          ? 'Search timed out.'
          : 'Could not reach Open Library.';
      return SearchFailure(msg);
    }
  }
}
