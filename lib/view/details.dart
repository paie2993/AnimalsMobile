import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../model/model.dart';
import '../model/response/response.dart';

class DetailsWidget extends StatelessWidget {
  DetailsWidget({
    super.key,
    required Future<Response<PetModel>> future,
  }) {
    _future = future;
  }

  late final Future<Response<PetModel>> _future;

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (final context, final snapshot) {
          developer.log(
            'Details FutureBuilder builder called',
            name: 'DetailsWidget:build',
          );
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }
          final response = snapshot.data!;
          if (!response.status) {
            final error = response.error!;
            return Center(
              child: Text('Error: $error'),
            );
          }
          final data = response.value!;
          developer.log(
            'Details FutureBuilder snapshot data: $data',
            name: 'DetailsWidget:build',
          );
          return Padding(
            padding: const EdgeInsets.all(16.00),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.00),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${data.name}'),
                    const SizedBox(height: 10),
                    Text('Breed: ${data.breed}'),
                    const SizedBox(height: 10),
                    Text('Age: ${data.age}'),
                    const SizedBox(height: 10),
                    Text('Weight: ${data.weight}'),
                    const SizedBox(height: 10),
                    Text('Owner: ${data.owner}'),
                    const SizedBox(height: 10),
                    Text('Location: ${data.location}'),
                    const SizedBox(height: 10),
                    Text('Description: ${data.description}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
