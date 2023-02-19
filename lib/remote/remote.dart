import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../model/response/response.dart';
import '../model/model.dart';

class Remote {
  static const _port = '2309';
  static const _baseAddress = 'http://10.0.2.2:$_port';
  static const _pets = '$_baseAddress/pets';
  static const _pet = '$_baseAddress/pet';
  static const _search = '$_baseAddress/search';

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<List<NameModel>>> getNames() async {
    developer.log(
      'Fetching all names from remote',
      name: 'Remote:getNames',
    );

    http.Response response;
    try {
      response = await http.get(Uri.parse(_pets));
    } on Exception catch (e) {
      developer.log(
        'Exception fetching names from remote',
        name: 'Remote:getNames',
      );
      return Response(status: false, error: e.toString());
    }

    if (response.statusCode != 200) {
      developer.log(
        'Failed to fetch names from remote',
        name: 'Remote:getNames',
      );
      return Response(status: false, error: response.body);
    }

    final body = response.body;
    final dynamicList = jsonDecode(body) as List<dynamic>;

    List<NameModel> list;
    try {
      list = dynamicList.map((e) => NameModel.fromJson(e)).toList();
    } on Exception catch (e) {
      developer.log(
        'Failed to convert the remote names into local model objects',
        name: 'Remote:getNames',
      );
      return Response(status: false, error: e.toString());
    }
    return Response(status: true, value: list);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<PetModel>> getPet(
    final int id,
  ) async {
    developer.log(
      'Fetching pet from remote',
      name: 'Remote:getPet',
    );

    final address = '$_pet/$id';
    http.Response response;
    try {
      response = await http.get(Uri.parse(address));
    } on Exception catch (e) {
      developer.log(
        'Exception fetching pet from remote',
        name: 'Remote:getPet',
      );
      return Response(status: false, error: e.toString());
    }

    if (response.statusCode != 200) {
      developer.log(
        'Failed to fetch pet from remote',
        name: 'Remote:getPet',
      );
      return Response(status: false, error: response.body);
    }

    final body = response.body;
    final dynamicMap = jsonDecode(body) as Map<String, dynamic>;

    late final PetModel pet;
    try {
      pet = PetModel.fromJson(dynamicMap);
    } on Exception catch (e) {
      developer.log(
        'Failed to convert the remote pet into local model objects',
        name: 'Remote:getPet',
      );
      return Response(status: false, error: e.toString());
    }
    return Response(status: true, value: pet);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<List<PetModel>>> getPets() async {
    developer.log(
      'Fetching pets from remote',
      name: 'Remote:getPets',
    );

    final uri = Uri.parse(_search);
    http.Response response;
    try {
      response = await http.get(uri);
    } on Exception catch (e) {
      developer.log(
        'Exception fetching pets from remote',
        name: 'Remote:getPets',
      );
      return Response(status: false, error: e.toString());
    }

    if (response.statusCode != 200) {
      developer.log(
        'Failed to fetch pets from remote',
        name: 'Remote:getPets',
      );
      return Response(status: false, error: response.body);
    }

    final body = response.body;
    final dynamicList = jsonDecode(body) as List<dynamic>;

    late final List<PetModel> list;
    try {
      list = dynamicList.map((e) => PetModel.fromJson(e)).toList();
    } on Exception catch (e) {
      developer.log(
        'Failed to convert the remote pets into local model objects',
        name: 'Remote:getPets',
      );
      return Response(status: false, error: e.toString());
    }

    return Response(status: true, value: list);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<int>> addPet(final PetModel data) async {
    developer.log(
      'Adding pet data to remote',
      name: 'Remote:addPet',
    );
    final body = jsonEncode(data);
    developer.log(
      'Attempting to send following pet to remote: $body',
      name: 'Remote:addPet',
    );

    late final Uri uri;
    try {
      uri = Uri.parse(_pet);
    } on Exception catch (e) {
      developer.log(
        'Failed to parse the uri',
        name: 'Remote:addPet',
      );
      return Response(status: false, error: e.toString());
    }

    late final http.Response response;
    try {
      response = await http.post(
        uri,
        body: body,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
    } on Exception catch (e) {
      developer.log(
        'Failed to add pet data remotely: request error',
        name: 'Remote:addPet',
      );
      return Response(status: false, error: e.toString());
    }

    if (response.statusCode != 200) {
      developer.log(
        'Failed to add pet data remotely: server error',
        name: 'Remote:addPet',
      );
      return Response(status: false, error: response.body);
    }
    final jsonBody = response.body;
    final jsonMap = jsonDecode(jsonBody);

    late final PetModel finance;
    try {
      finance = PetModel.fromJson(jsonMap);
    } on Exception catch (e) {
      developer.log(
        'Failed to convert remote data to local model',
        name: 'Remote:addPet',
      );
      return Response(status: false, error: e.toString());
    }
    return Response(status: true, value: finance.id);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<Response<bool>> deletePet(final int id) async {
    developer.log(
      'Attempting to delete pet remotely',
      name: 'Remote:deletePet',
    );
    late final Uri uri;
    try {
      uri = Uri.parse('$_pet/$id');
    } on Exception catch (e) {
      developer.log(
        'Failed to parse uri for DELETE',
        name: 'Remote:deletePet',
      );
      return Response(status: false, error: e.toString());
    }

    late final http.Response response;
    try {
      response = await http.delete(uri).timeout(const Duration(seconds: 5));
    } on Exception catch (e) {
      developer.log(
        'Failed to delete pet remotely: request error',
        name: 'Remote:deletePet',
      );
      return Response(status: false, value: null, error: e.toString());
    }
    if (response.statusCode != 200) {
      developer.log(
        'Failed to delete pet remotely: server error',
        name: 'Remote:deletePet',
      );
      return Response(status: false, error: response.body);
    }
    return const Response(status: true, value: true);
  }
}
