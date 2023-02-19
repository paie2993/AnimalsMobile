import 'package:base/view/search.dart';
import 'package:base/view_model/search_vm.dart';
import 'package:flutter/material.dart';

class QueryWidget<T> extends StatefulWidget {
  QueryWidget({
    super.key,
    required final SearchViewModel searchViewModel,
  }) {
    _searchViewModel = searchViewModel;
  }

  late final SearchViewModel _searchViewModel;

  @override
  State<StatefulWidget> createState() => _QueryState();
}

class _QueryState extends State<QueryWidget> {
  final _breed = TextEditingController();
  final _age = TextEditingController();
  final _location = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _breed.dispose();
    _age.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.00),
        child: ListView(
          children: [
            TextField(
              controller: _breed,
              decoration: const InputDecoration(
                label: Text('Breed'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _age,
              decoration: const InputDecoration(
                label: Text('Age'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _location,
              decoration: const InputDecoration(
                label: Text('Location'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _search(context),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  void _search(final BuildContext context) {
    final breed = _breed.text;
    final stringAge = _age.text;
    final location = _location.text;

    final age = int.tryParse(stringAge);
    if (age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid age'),
        ),
      );
    }

    final future = widget._searchViewModel.search(
      breed: breed.isNotEmpty ? breed : null,
      age: age,
      location: location.isNotEmpty ? location : null,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (final context) {
          return SearchWidget(future: future);
        },
      ),
    );
  }
}
