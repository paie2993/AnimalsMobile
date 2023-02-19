import '../model/model.dart';
import 'dart:developer' as developer;

List<PetModel> process({
  required final List<PetModel> list,
  final String? breed,
  final int? age,
  final String? location,
}) {
  developer.log(
    'Attempting to process: $list',
    name: 'process',
  );
  if (breed != null) {
    list.retainWhere((element) => breed == element.breed);
  }
  developer.log(
    'After filtering by breed: $list',
    name: 'process',
  );
  if (age != null) {
    list.retainWhere((element) => age == element.age);
  }
  developer.log(
    'After filtering by age: $list',
    name: 'process',
  );
  if (location != null) {
    list.retainWhere((element) => location == element.location);
  }
  developer.log(
    'After filtering by location: $list',
    name: 'process',
  );
  list.sort((final first, final second) {
    final weightComparison = -first.weight.compareTo(second.weight);
    if (weightComparison == 0) {
      return first.age.compareTo(second.age);
    }
    return weightComparison;
  });
  developer.log(
    'After sorting: $list',
    name: 'process',
  );
  developer.log('Processed data; output: $list', name: 'process');
  return list;
}
