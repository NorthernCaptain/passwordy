import 'package:flutter/material.dart';
import 'package:passwordy/service/database.dart';
import 'package:passwordy/service/db_vault.dart';
import 'package:passwordy/service/log.dart';
import 'package:passwordy/widgets/add_options_state.dart';
import 'package:passwordy/widgets/empty_state.dart';
import 'package:passwordy/widgets/new_item_chooser.dart';
import 'package:passwordy/widgets/search_widget.dart';

class VaultListScreen extends AddOptionsWidget {
  VaultListScreen({Key? key}) : super(key: key);

  @override
  _VaultListScreenState createState() => _VaultListScreenState();
}

class _VaultListScreenState
    extends State<VaultListScreen> with KeyedAddOptionsState<VaultListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SearchWidget(onSearch: _handleSearch),
              Expanded(child: EmptyState()),
            ]
        )
    );
  }

  void _handleSearch(String query) {
    lg?.i('Searching for: $query');
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
            print('Selected: $item.title');
            // Add your logic here to handle the selected item
          },
        );
      },
    );
  }
}