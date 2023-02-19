import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'localdb.g.dart';

// Name - the name of the pet. A string of characters.
// ● Breed - the breed of the pet. A string of characters.
// ● Age - the age of the pet in years. Integer value.
// ● Weight - the weight of the pet in pounds. Integer value.
// ● Owner - the name of the pet owner. A string of characters.
// ● Location - the location of the pet owner. A string of characters.
// ● Description - any additional information added by the owner about the pet. A string of
// characters.

@DataClassName('Name')
class Names extends Table {
  @override
  String get tableName => 'names';

  IntColumn get id => integer()();

  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Pet')
class Pets extends Table {
  @override
  String get tableName => 'pets';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get breed => text()();

  IntColumn get age => integer()();

  IntColumn get weight => integer()();

  TextColumn get owner => text()();

  TextColumn get location => text()();

  TextColumn get description => text()();
}

@DriftDatabase(tables: [Names, Pets])
class Local extends _$Local {
  Local() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        await m.deleteTable('names');
        await m.deleteTable('pets');
        await m.createAll();
      },
    );
  }

  Stream<List<Name>> get namesStream => select(names).watch();

  Future<bool> setNames(List<NamesCompanion> data) async {
    try {
      await delete(names).go();
    } on Exception {
      developer.log(
        'Exception clearing the names from the local database',
        name: 'Local:setNames',
      );
      return false;
    }
    developer.log(
      'Managed to clear the names from the local database',
      name: 'Local:setNames',
    );

    try {
      await batch(
        (batch) {
          batch.insertAllOnConflictUpdate(names, data);
        },
      );
    } on Exception {
      developer.log(
        'Exception adding the remote names to the local database',
        name: 'Local:setNames',
      );
      return false;
    }

    developer.log(
      'Managed to add the remote names to the local database',
      name: 'Local:setNames',
    );
    return true;
  }

  Future<bool> setPets(
    final List<PetsCompanion> data,
    final int id,
  ) async {
    try {
      await (delete(pets)..where((tbl) => tbl.id.equals(id))).go();
    } on Exception {
      developer.log(
        'Exception clearing the pets from the local database',
        name: 'Local:setPets',
      );
      return false;
    }
    developer.log(
      'Managed to clear the pets from the local database',
      name: 'Local:setPets',
    );

    try {
      await batch(
        (batch) {
          batch.insertAllOnConflictUpdate(pets, data);
        },
      );
    } on Exception {
      developer.log(
        'Exception adding the remote pets to the local database',
        name: 'Local:setPets',
      );
      return false;
    }

    developer.log(
      'Managed to add the remote pets to the local database',
      name: 'Local:setPets',
    );

    return true;
  }

  Future<bool> getPets(final int id) async {
    final synced = _syncPets(id);
    return synced;
  }

  Future<bool> addPet(final PetsCompanion pet) async {
    developer.log(
      'Adding pet locally: $pet',
      name: 'Local:addPet',
    );
    try {
      await into(pets).insertOnConflictUpdate(pet);
    } on Exception {
      developer.log(
        'Failed to add pet locally',
        name: 'Local:addPet',
      );
      return false;
    }

    final id = pet.id.value;
    final synced = _syncPets(id);
    return synced;
  }

  Future<bool> deletePet(final int id) async {
    developer.log(
      'Deleting pet locally',
      name: 'Local:deletePet',
    );
    try {
      await (delete(pets)..where((tbl) => tbl.id.equals(id))).go();
    } on Exception {
      developer.log(
        'Failed to delete finance locally: database error',
        name: 'Local:deletePet',
      );
      return false;
    }
    final synced = await _syncPets(id);
    return synced;
  }

  Future<bool> _syncPets(final int id) async {
    final list = await _getPets(id);
    if (list == null) {
      developer.log(
        'Failed to fetch local pets',
        name: 'Local:_syncPets',
      );
      return false;
    }
    return true;
  }

  Future<List<Pet>?> _getPets(final int id) async {
    late final List<Pet> list;
    try {
      list = await (select(pets)..where((t) => t.id.equals(id))).get();
    } on Exception {
      developer.log(
        'Exception fetching local pets',
        name: 'Local:_getPets',
      );
      return null;
    }
    developer.log(
      'Fetched pets from local database: $list',
      name: 'Local:_getPets',
    );
    return list;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(
    () async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase.createInBackground(file);
    },
  );
}
