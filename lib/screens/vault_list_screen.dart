import 'package:flutter/material.dart';
import 'package:passwordy/screens/add_secret_screen.dart';
import 'package:passwordy/screens/display_secret_screen.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/service/log.dart';
import 'package:passwordy/service/utils.dart';
import 'package:passwordy/widgets/add_options_state.dart';
import 'package:passwordy/widgets/circle_icon.dart';
import 'package:passwordy/widgets/empty_state.dart';
import 'package:passwordy/widgets/new_item_chooser.dart';
import 'package:passwordy/widgets/search_widget.dart';

class VaultListScreen extends AddOptionsWidget {
  final Vault vault;
  VaultListScreen({super.key, required this.vault});

  @override
  _VaultListScreenState createState() => _VaultListScreenState();
}

class _VaultListScreenState
    extends State<VaultListScreen> with KeyedAddOptionsState<VaultListScreen> {
  String _searchQuery = '';
  late Stream<List<Template>> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = Vault.vault.watchActiveDataTemplates(filter: _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SearchWidget(onSearch: _handleSearch),
          Expanded(
            child: StreamBuilder<List<Template>>(
              stream: _dataStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                if (data.isEmpty) {
                  return widget.vault.isConnected
                      ? const EmptyState()
                      : const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return _buildListItem(context, data[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildListItem(BuildContext context, Template item) {
    return Dismissible(
      key: Key('v-item-${item.id}'),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: Text("Are you sure you want to delete ${item.title}?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        // Delete the item from the database
        widget.vault.transaction(() async => widget.vault.deleteTemplate(item));
        snackInfo(context, '${item.title} deleted');
      },
      child: _buildEntry(context, item),
    );
  }

  Widget _buildEntry(BuildContext context, Template entry) {
    return ListTile(
      leading: CircleIcon(iconName: entry.icon, backgroundColor: entry.color),
      title: Text(
        entry.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        entry.category ?? "",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      ),
      onTap: () {
        // Handle item tap
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => DisplaySecretScreen(template: entry, vault: widget.vault,)));
      },
    );
  }

  void _handleSearch(String query) {
    lg?.i('Searching for: $query');
    setState(() {
      _searchQuery = query;
      _dataStream = Vault.vault.watchActiveDataTemplates(filter: _searchQuery);
    });
  }

  @override
  void showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return NewItemChooser(
          vault: Vault.vault,
          onItemSelected: (Template item) {
            // Handle the selected item
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddSecretScreen(template: item, vault: widget.vault,)));
          },
        );
      },
    );
  }
}