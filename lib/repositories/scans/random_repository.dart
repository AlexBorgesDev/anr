part of '../scan_base_repository.dart';

class RandomRepository extends ScanBaseRepository {
  RandomRepository();

  Scan get scan => Scan.random;

  @override
  List<String> get baseURLs => ['https://randomscans.com', 'https://randomscan.online'];

  @override
  Future<List<Book>> lastAdded() {
    return _tryWithAllBaseUrls<List<Book>>(
      defaultValue: List.empty(),
      callback: (baseURL) async {
        final books = <Book>[];

        final response = await dio.get(baseURL);
        final $ = parse(response.data);

        for (Element element in $.querySelectorAll('#loop-content .page-item-detail')) {
          final scraping = ScrapingUtil(element);

          final src = scraping.getSrc(selector: 'img') ?? scraping.getSrc(selector: 'img', bySrcSet: true);
          final path = scraping.getURL(selector: 'h3 a');
          final name = scraping.getByText(selector: 'h3 a');

          if (scraping.hasEmptyOrNull([src, path, name])) continue;

          books.add(Book(src: src!, name: name, path: path, scan: scan));
        }

        return books;
      },
    );
  }

  @override
  Future<List<Book>> search(String value) {
    return _tryWithAllBaseUrls<List<Book>>(
      defaultValue: List.empty(),
      callback: (baseURL) async {
        final books = <Book>[];

        final url = '$baseURL/?s=$value&post_type=wp-manga';
        final response = await dio.get(url);
        final $ = parse(response.data);

        for (Element element in $.querySelectorAll('.c-tabs-item div.row')) {
          final scraping = ScrapingUtil(element);

          final src = scraping.getSrc(selector: 'img') ?? scraping.getSrc(selector: 'img', bySrcSet: true);
          final path = scraping.getURL(selector: 'h3 a');
          final name = scraping.getByText(selector: 'h3 a');

          if (scraping.hasEmptyOrNull([src, path, name])) continue;

          books.add(Book(src: src!, name: name, path: path, scan: scan));
        }

        return books;
      },
    );
  }

  @override
  Future<BookData> data(Book book) async {
    return _tryWithAllBaseUrls<BookData>(
      path: book.path,
      callback: (baseURL) async {
        final response = await dio.get(baseURL);
        final $ = parse(response.data);

        final scanScrapingUtil = ScanScrapingUtil($);
        final categories = scanScrapingUtil.categories();
        final type = scanScrapingUtil.type(alternativeType: book.type);
        final sinopse = scanScrapingUtil.sinopse();

        // Chapters ------------------------------------------------

        final chaptersElements = await _chapterElements(baseURL);
        final chapters = await _chapters(
          items: chaptersElements,
          transform: (value) => ScrapingUtil(value),
          callback: (item) {
            final url = item.getURL();
            final name = item.getByText();

            if (item.hasEmptyOrNull([url, name])) return null;
            return ChapterBase(name: name, url: url, bookSlug: book.slug);
          },
        );

        return BookData(chapters: chapters, sinopse: sinopse, categories: categories, type: type);
      },
    );
  }
}
