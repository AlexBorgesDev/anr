import 'package:anr/models/book.dart';
import 'package:mobx/mobx.dart';

part 'search_store.g.dart';

// ignore: library_private_types_in_public_api
class SearchStore = _SearchStore with _$SearchStore;

abstract class _SearchStore with Store {
  @observable
  bool isLoading = false;

  @observable
  ObservableList<Book> results = ObservableList();

  @action
  void setIsLoading(bool loading) {
    isLoading = loading;
  }
}
