part of 'package:anr/repositories/scans/base_scan_repository.dart';

class MangaLivreRepository extends BaseScanRepository {
  static final MangaLivreRepository instance = MangaLivreRepository._internal();
  factory MangaLivreRepository() => instance;

  MangaLivreRepository._internal();

  final baseURL = Uri.parse('https://mangalivre.net');
  final scan = Scan.mangaLivre;

  @override
  Future<List<BookItem>> lastAdded({forceUpdate = false}) async {
    final url = baseURL.replace(path: '/home/releases', query: 'page=1&type=');
    final response = await httpRepository.get(url, forceUpdate: forceUpdate);

    final items = <BookItem>[];
    final data = jsonDecode(response.body);

    for (final item in data['releases'] ?? List.empty(growable: false)) {
      final src = item['image_thumb'] ?? item['image'];

      if (src.contains('blurred')) continue;

      items.add(BookItem(
        src: item['image_thumb'] ?? item['image'],
        name: item['name'].toString().trim(),
        path: item['link'],
        scan: scan,
        webID: item['id_serie'],
      ));
    }

    return items;
  }

  @override
  Future<List<BookItem>> search(String value, {bool forceUpdate = false}) async {
    final url = baseURL.replace(path: '/lib/search/series.json');
    final response = await httpRepository.post(
      url,
      body: {'search': value},
      headers: {"x-requested-with": "XMLHttpRequest"},
      forceUpdate: forceUpdate,
    );

    final items = <BookItem>[];
    final data = jsonDecode(response.body);

    for (final item in data['series'] ?? List.empty(growable: false)) {
      items.add(BookItem(
        src: item['image_thumb'] ?? item['image'] ?? item['cover_thumb'] ?? item['cover'],
        name: item['name'].toString().trim(),
        path: item['link'],
        scan: scan,
        webID: item['id_serie'],
      ));
    }

    return items;
  }
}
