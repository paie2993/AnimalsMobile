import '../logic/search_logic.dart';
import '../model/model.dart';
import '../model/response/response.dart';
import '../repo/repo.dart';
import 'dart:developer' as developer;

class SearchViewModel {
  SearchViewModel({
    required repo,
  }) {
    _repo = repo;
  }

  late final Repo _repo;

  Future<Response<List<PetModel>>> search({
    final String? breed,
    final int? age,
    final String? location,
  }) async {
    final repoResponse = await _repo.getPets();
    if (!repoResponse.status) {
      return Response(status: false, error: repoResponse.error);
    }
    developer.log(
      'Fetched data: ${repoResponse.value!}',
      name: 'SearchViewModel',
    );
    final list = process(
      list: repoResponse.value!,
      breed: breed,
      age: age,
      location: location,
    );
    return Response(status: true, value: list);
  }
}
