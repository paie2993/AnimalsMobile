import 'package:drift/drift.dart';

import '../local/localdb.dart';

class NameModel {
  NameModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  NameModel.fromRow(final Name name)
      : id = name.id,
        name = name.name;

  NamesCompanion toRow() => NamesCompanion.insert(
        id: Value(id),
        name: name,
      );

  NameModel.fromJson(final Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

// Name - the name of the pet. A string of characters.
// ● Breed - the breed of the pet. A string of characters.
// ● Age - the age of the pet in years. Integer value.
// ● Weight - the weight of the pet in pounds. Integer value.
// ● Owner - the name of the pet owner. A string of characters.
// ● Location - the location of the pet owner. A string of characters.
// ● Description - any additional information added by the owner about the pet. A string of
// characters.

class PetModel {
  PetModel({
    this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.weight,
    required this.owner,
    required this.location,
    required this.description,
  });

  final int? id;
  final String name;
  final String breed;
  final int age;
  final int weight;
  final String owner;
  final String location;
  final String description;

  PetModel.fromRow(final Pet pet)
      : id = pet.id,
        name = pet.name,
        breed = pet.breed,
        age = pet.age,
        weight = pet.weight,
        owner = pet.owner,
        location = pet.location,
        description = pet.description;

  PetsCompanion toRow() => PetsCompanion(
        id: id != null ? Value(id!) : const Value.absent(),
        name: Value(name),
        breed: Value(breed),
        age: Value(age),
        weight: Value(weight),
        owner: Value(owner),
        location: Value(location),
        description: Value(description),
      );

  PetModel.fromJson(final Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        breed = json['breed'],
        age = json['age'],
        weight = json['weight'],
        owner = json['owner'],
        location = json['location'],
        description = json['description'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'breed': breed,
        'age': age,
        'weight': weight,
        'owner': owner,
        'location': location,
        'description': description,
      };

  @override
  String toString() {
    return 'id: $id , name: $name, breed: $breed , age: $age, weight: $weight , owner: $owner , location: $location, description: $description';
  }
}
