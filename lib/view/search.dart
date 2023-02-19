import 'package:flutter/material.dart';

import '../model/model.dart';
import '../model/response/response.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({
    super.key,
    required final Future<Response<List<PetModel>>> future,
  }) {
    _future = future;
  }

  late final Future<Response<List<PetModel>>> _future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.00),
        child: FutureBuilder(
          future: _future,
          builder: (final context, final snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final response = snapshot.data!;
            if (!response.status) {
              return Center(
                child: Text('Error: ${response.error!}'),
              );
            }
            final data = response.value!;
            if (data.isEmpty) {
              return const Center(
                child: Text('No data :('),
              );
            }
            return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (final context, final index) => const Divider(),
              itemBuilder: (final context, final index) {
                final item = data[index];
                return ListTile(
                  leading: const Icon(
                    Icons.pets_sharp,
                    color: Colors.amber,
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    'Breed: ${item.breed}, Age: ${item.age}, Location: ${item.location}',
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
