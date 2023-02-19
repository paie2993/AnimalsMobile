import '../model/model.dart';
import '../repo/repo.dart';

class ConnectionViewModel {
  ConnectionViewModel({
    required Repo repo,
  }) {
    _repo = repo;
  }

  late final Repo _repo;

  bool get connected => _repo.connected;

  Stream<PetModel> get stream => _repo.remotePetsStream;

  void switchConnection() => _repo.switchConnection();
}
