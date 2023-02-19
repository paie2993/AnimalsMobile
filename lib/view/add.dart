import 'package:base/model/model.dart';
import 'package:base/view_model/add_vm.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AddWidget extends StatefulWidget {
  AddWidget({
    super.key,
    required AddViewModel addViewModel,
  }) {
    _addViewModel = addViewModel;
  }

  late final AddViewModel _addViewModel;

  @override
  State<StatefulWidget> createState() => _AddState();
}

class _AddState extends State<AddWidget> {
  final GlobalKey<FormState> _globalKey = GlobalKey();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _breed = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _owner = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _description = TextEditingController();

  final RegExp _ageRegExp = RegExp(r'^[1-9][0-9]*$');
  final RegExp _weightRegExp = RegExp(r'^[0-9]+$');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _breed.dispose();
    _age.dispose();
    _weight.dispose();
    _owner.dispose();
    _location.dispose();
    _description.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.00),
        child: Form(
          key: _globalKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  label: Text('Name'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.00),
              TextFormField(
                controller: _breed,
                decoration: const InputDecoration(
                  label: Text('Breed'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.00),
              TextFormField(
                controller: _age,
                validator: (final value) => _ageValidator(value),
                decoration: const InputDecoration(
                  label: Text('Age'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.00),
              TextFormField(
                controller: _weight,
                validator: (final value) => _weightValidator(value),
                decoration: const InputDecoration(
                  label: Text('Weight'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.00),
              TextFormField(
                controller: _owner,
                decoration: const InputDecoration(
                  label: Text('Owner'),
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                  label: Text('Location'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.00),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(
                  label: Text('Description'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15.00),
              const SizedBox(height: 15.00),
              TextButton(
                onPressed: () => _pressedAddButton(context),
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _ageValidator(final String? value) {
    if (value == null) {
      developer.log(
        'Age value is null: not allowed',
        name: '_AddState:_ageValidator',
      );
      return 'Age cannot be null';
    }
    if (!_ageRegExp.hasMatch(value)) {
      developer.log(
        'Age value does not follow the date format',
        name: '_AddState:_ageValidator',
      );
      return 'Age format not followed';
    }
    return null;
  }

  String? _weightValidator(final String? value) {
    if (value == null) {
      developer.log(
        'Weight value is null: not allowed',
        name: '_AddState:_weightValidator',
      );
      return 'Weight cannot be null';
    }
    if (!_weightRegExp.hasMatch(value)) {
      developer.log(
        'Weight value does not follow the amount format',
        name: '_AddState:_weightValidator',
      );
      return 'Weight format not followed';
    }
    return null;
  }

  void _pressedAddButton(final BuildContext context) async {
    if (!_globalKey.currentState!.validate()) {
      developer.log(
        'Form did not pass validation',
        name: '_AddState:_pressedAddButton',
      );
      return;
    }
    developer.log(
      'Form passed validation',
      name: '_AddState:_pressedAddButton',
    );
    late final PetModel? entity;
    try {
      entity = _buildEntity();
    } on Exception {
      developer.log(
        'Exception building entity from given form data',
        name: '_AddState:_pressedAddButton',
      );
      return;
    }
    if (entity == null) {
      developer.log(
        'Failed to build entity from given form data',
        name: '_AddState:_pressedAddButton',
      );
      return;
    }
    widget._addViewModel.add(entity);
    Navigator.of(context).pop();
  }

  PetModel? _buildEntity() {
    final name = _name.text;
    final breed = _breed.text;
    final age = _age.text;
    final weight = _weight.text;
    final owner = _owner.text;
    final location = _location.text;
    final description = _description.text;

    final intAge = int.tryParse(age);
    final intWeight = int.tryParse(weight);

    if (intAge == null || intWeight == null) {
      return null;
    }

    return PetModel(
      name: name,
      breed: breed,
      age: intAge,
      weight: intWeight,
      owner: owner,
      location: location,
      description: description,
    );
  }
}
