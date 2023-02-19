import 'package:base/view/add.dart';
import 'package:base/view/query.dart';
import 'package:base/view_model/connection_vm.dart';
import 'package:base/view_model/search_vm.dart';
import 'package:flutter/material.dart';
import '../model/model.dart';
import '../view_model/add_vm.dart';
import '../view_model/list_vm.dart';
import 'details.dart';

class ListWidget extends StatefulWidget {
  ListWidget({
    super.key,
    required ListViewModel listViewModel,
    required final SearchViewModel searchViewModel,
    required AddViewModel addViewModel,
    required ConnectionViewModel connectionViewModel,
  }) {
    _listViewModel = listViewModel;
    _searchViewModel = searchViewModel;
    _addViewModel = addViewModel;
    _connectionViewModel = connectionViewModel;
  }

  late final ListViewModel _listViewModel;
  late final SearchViewModel _searchViewModel;
  late final AddViewModel _addViewModel;
  late final ConnectionViewModel _connectionViewModel;

  @override
  State<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  bool? _light;

  late final MaterialStateProperty<Icon?> _thumbIcon;

  late final MaterialStateProperty<Color?> _trackColor;

  @override
  void initState() {
    super.initState();
    _thumbIcon = _resolveThumbIcon();
    _trackColor = _resolveTrackColor();
    _light = widget._connectionViewModel.connected;
  }

  @override
  void dispose() {
    _light = false;
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List ${widget._connectionViewModel.connected ? '(online)' : '(offline)'}',
        ),
        actions: [
          Switch(
            value: _light!,
            thumbIcon: _thumbIcon,
            trackColor: _trackColor,
            onChanged: (final value) {
              setState(() {
                widget._connectionViewModel.switchConnection();
                _light = value;
              });
            },
          ),
          IconButton(
            onPressed: () => !widget._connectionViewModel.connected
                ? _pressOnlineOnlyFeature(context)
                : _pressSearch(context),
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => !widget._connectionViewModel.connected
            ? _pressOnlineOnlyFeature(context)
            : _pressActionButton(context),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: widget._connectionViewModel.stream,
            builder: (final context, final snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Name: ${data.name}, Breed: ${data.breed}, Age: ${data.age}, Weight: ${data.weight}, Owner: ${data.owner}, Location: ${data.location}, Description: ${data.description}',
                    ),
                  ));
                });
              }
              return const SizedBox();
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: widget._listViewModel.datesStream,
              builder: (final context, final snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final data = snapshot.data!;
                return ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (final context, final index) =>
                      const Divider(),
                  itemBuilder: (final context, final index) {
                    final item = data[index];
                    return !widget._connectionViewModel.connected
                        ? _unDeletableTile(context, item)
                        : _deletableTile(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  MaterialStateProperty<Icon?> _resolveThumbIcon() =>
      MaterialStateProperty.resolveWith(
        (final states) {
          if (states.contains(MaterialState.selected)) {
            return const Icon(Icons.check, color: Colors.white);
          }
          return const Icon(Icons.close, color: Colors.blue);
        },
      );

  MaterialStateProperty<Color?> _resolveTrackColor() =>
      MaterialStateProperty.resolveWith((final states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.grey.shade300;
        }
        return Colors.grey.shade500;
      });

  void _pressOnlineOnlyFeature(final BuildContext context) async {
    showDialog(
      context: context,
      builder: (final context) {
        return AlertDialog(
          title: const Text('Offline'),
          content: const Text('Selected feature is only available Online'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _pressSearch(final BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (final context) {
          return QueryWidget(
            searchViewModel: widget._searchViewModel,
          );
        },
      ),
    );
  }

  void _tapListItem(final BuildContext context, final int id) async {
    final pet = widget._listViewModel.getPet(id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (final context) {
          return DetailsWidget(future: pet);
        },
      ),
    );
  }

  void _dismiss(
    final BuildContext context,
    final DismissDirection direction,
    final int id,
  ) async {
    await widget._listViewModel.deletePet(id);
  }

  Widget _deletableTile(final BuildContext context, final NameModel item) {
    return Dismissible(
      key: Key(item.id.toString()),
      onDismissed: (final direction) => _dismiss(context, direction, item.id),
      child: _simpleTile(context, item),
    );
  }

  Widget _unDeletableTile(final BuildContext context, final NameModel item) {
    return GestureDetector(
      onHorizontalDragEnd: (final details) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting Pets is only available online'),
          ),
        );
      },
      child: _simpleTile(context, item),
    );
  }

  Widget _simpleTile(final BuildContext context, final NameModel item) {
    return GestureDetector(
      onTap: () => _tapListItem(context, item.id),
      child: ListTile(
        leading: const Icon(
          Icons.pets,
          color: Colors.blue,
        ),
        title: Text(item.name),
      ),
    );
  }

  void _pressActionButton(final BuildContext context) {
    if (!widget._connectionViewModel.connected) {
      showDialog(
        context: context,
        builder: (final context) {
          return AlertDialog(
            title: const Text('Offline'),
            content: const Text('Adding pets is only available online'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (final context) {
          return AddWidget(
            addViewModel: widget._addViewModel,
          );
        },
      ),
    );
  }
}
