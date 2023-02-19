import '../model/model.dart';
import '../model/response/response.dart';
import '../repo/repo.dart';

class ListViewModel {
  ListViewModel({
    required repo,
  }) {
    _repo = repo;
  }

  late final Repo _repo;

  Stream<List<NameModel>> get datesStream => _repo.localNamesStream;

  Future<Response<PetModel>> getPet(final int id) => _repo.getPet(id);

  Future<void> deletePet(final int id) async => await _repo.deletePet(id);
}
