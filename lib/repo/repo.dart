import 'dart:async';
import 'dart:convert';

import 'package:base/local/localdb.dart';
import 'package:base/model/model.dart';
import 'package:base/remote/remote.dart';
import 'package:drift/drift.dart';
import 'dart:developer' as developer;

import '../model/response/response.dart';
import '../remote/connection_manager.dart';

class Repo {
  Repo({
    required local,
    required remote,
    required connectionManager,
  }) {
    _local = local;
    _remote = remote;
    _connectionManager = connectionManager;
  }

  late final Local _local;
  late final Remote _remote;
  late final ConnectionManager _connectionManager;

  void initialize() {
    _subscribeLocalNames();
    _subscribeRemotePets();
    getNames();
  }

  //////////////////////////////////////////////////////////////////////////////
  final StreamController<List<NameModel>> _localNamesStreamController =
      StreamController.broadcast();

  final StreamController<PetModel> _remotePetsStreamController =
      StreamController.broadcast();

  Stream<List<NameModel>> get localNamesStream =>
      _localNamesStreamController.stream;

  Stream<PetModel> get remotePetsStream => _remotePetsStreamController.stream;

  //////////////////////////////////////////////////////////////////////////////

  bool get connected => _connectionManager.connected;

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<bool>> getNames() async {
    developer.log(
      'Repo call *****************************',
      name: 'Repo:getNames',
    );
    developer.log(
      'Attempting to fetch remote names',
      name: 'Repo:getNames',
    );
    if (!_connectionManager.connected) {
      developer.log(
        'Failed to fetch remote names: remote connection is offline',
        name: 'Repo:getNames',
      );
      return const Response(status: false, error: 'Connection is offline');
    }
    final remoteResponse = await _remote.getNames();
    if (!remoteResponse.status) {
      developer.log(
        'Failed tot fetch remote names',
        name: 'Repo:getNames',
      );
      return Response(status: false, error: remoteResponse.error!);
    }
    final list = remoteResponse.value!;
    final persistableEntities = list.map((e) => e.toRow()).toList();
    _local.setNames(persistableEntities);
    return const Response(status: true, value: true);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<PetModel>> getPet(int id) async {
    developer.log(
      'Repo call *****************************',
      name: 'Repo:getPet',
    );
    if (!_connectionManager.connected) {
      developer.log(
        'Failed to fetch pet: connection is offline',
        name: 'Repo:getPet',
      );
      return const Response(status: false, error: 'Connection is offline');
    }
    final remoteResponse = await _remote.getPet(id);
    if (!remoteResponse.status) {
      developer.log(
        'Failed to fetch pet: processing error',
        name: 'Repo:getPet',
      );
      return Response(status: false, error: remoteResponse.error);
    }
    final entity = remoteResponse.value!;
    developer.log(
      'Fetched pet from remote: $entity',
      name: 'Repo:getPet',
    );
    return Response(status: true, value: entity);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<List<PetModel>>> getPets() async {
    developer.log(
      'Repo call *****************************',
      name: 'Repo:getPets',
    );
    if (!_connectionManager.connected) {
      developer.log(
        'Failed to fetch pets: connection is offline',
        name: 'Repo:getPets',
      );
      return const Response(status: false, error: 'Connection is offline');
    }
    final remoteResponse = await _remote.getPets();
    if (!remoteResponse.status) {
      developer.log(
        'Failed to fetch pets: processing error',
        name: 'Repo:getPets',
      );
      return Response(status: false, error: remoteResponse.error);
    }
    final list = remoteResponse.value!;
    developer.log(
      'Fetched pets from remote: $list',
      name: 'Repo:getPets',
    );
    return Response(status: true, value: list);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<bool>> addPet(final PetModel pet) async {
    developer.log(
      'Repo call *****************************',
      name: 'Repo:addPet',
    );
    if (!_connectionManager.connected) {
      developer.log(
        'Failed to add pet: connection is offline',
        name: 'Repo:addPet',
      );
      return const Response(status: false, error: 'Connection is offline');
    }
    final remoteResponse = await _remote.addPet(pet);
    if (!remoteResponse.status) {
      developer.log(
        'Failed to add pet remotely',
        name: 'Repo:addPet',
      );
      return Response(status: false, error: remoteResponse.error);
    }

    final id = remoteResponse.value!;
    final persistableEntity = pet.toRow().copyWith(id: Value(id));
    final status = await _local.addPet(persistableEntity);
    if (status == false) {
      return const Response(
        status: false,
        error: 'Failed to add pet locally',
      );
    }
    return const Response(status: true, value: true);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<bool>> deletePet(final int id) async {
    if (!_connectionManager.connected) {
      developer.log(
        'Cannot delete pet: connection is offline',
        name: 'Repo:deletePet',
      );
      return const Response(status: false, error: 'Connection is offline');
    }

    final remoteResponse = await _remote.deletePet(id);
    if (!remoteResponse.status) {
      developer.log(
        'Failed to delete pet remotely, due to error',
        name: 'Repo:deletePet',
      );
      return Response(status: false, error: remoteResponse.error);
    }

    if (!remoteResponse.value!) {
      developer.log(
        'Failed to delete pet remotely, request rejected',
        name: 'Repo:deletePet',
      );
      return Response(status: false, error: remoteResponse.error);
    }

    late final bool locallyDeleted;
    try {
      locallyDeleted = await _local.deletePet(id);
    } on Exception catch (e) {
      developer.log(
        'Failed to delete pet locally, due to error',
        name: 'Repo:deletePet',
      );
      return Response(status: false, error: e.toString());
    }

    if (!locallyDeleted) {
      developer.log(
        'Failed to delete pet locally, due to processing failure',
        name: 'Repo:deletePet',
      );
      return const Response(
        status: false,
        error: 'Failed to delete pet locally',
      );
    }
    return const Response(status: true, value: true);
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  void switchConnection() async {
    if (_connectionManager.connected) {
      _connectionManager.disconnect();
    }
    final status = await _connectionManager.connect();
    if (!status) {
      developer.log('Could not connect ws', name: 'Repo:switchConnection');
    }
    developer.log('Connected ws', name: 'Repo:switchConnection');
    getNames();
  }

  void _subscribeLocalNames() {
    _local.namesStream.listen(
      (final List<Name> list) {
        final entities = list.map((e) => NameModel.fromRow(e)).toList();
        _localNamesStreamController.sink.add(entities);
      },
    );
  }

  void _subscribeRemotePets() {
    if (!_connectionManager.connected) {
      developer.log(
        'Failed to connect websocket to remote server',
        name: 'Repo:_subscribeRemotePets',
      );
      return;
    }
    _connectionManager.stream?.listen(
      (final event) {
        developer.log(
          'Received event from remote server through websocket incoming stream: $event',
          name: 'Repo:_subscribeRemotePets',
        );
        final jsonMap = jsonDecode(event);
        final pet = PetModel.fromJson(jsonMap);
        _remotePetsStreamController.sink.add(pet);
        developer.log(
          'Sent through outgoing stream: $pet',
          name: 'Repo:_subscribeRemotePets',
        );
      },
    );
  }
}
