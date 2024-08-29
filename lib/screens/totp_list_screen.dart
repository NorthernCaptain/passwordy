import 'package:flutter/material.dart';
import 'package:passwordy/screens/add_secret_screen.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/db/datavalues_dao.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'dart:async';
import 'package:passwordy/service/totp.dart';
import 'package:passwordy/service/utils.dart';
import 'package:passwordy/widgets/add_options_state.dart';
import 'package:passwordy/widgets/empty_state.dart';
import 'package:passwordy/widgets/new_item_chooser.dart';
import 'package:passwordy/widgets/otp_tile.dart';

class AuthenticatorScreen extends AddOptionsWidget {
  final Vault vault;
  AuthenticatorScreen({super.key, required this.vault});

  @override
  _AuthenticatorScreenState createState() => _AuthenticatorScreenState();
}

class _AuthenticatorScreenState
    extends State<AuthenticatorScreen> with KeyedAddOptionsState<AuthenticatorScreen> {
  late Stream<List<DataWithAllTemplate>> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = widget.vault.watchActiveTokenTemplates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddOptions(context),
          ),
        ],
      ),
      body: StreamBuilder<List<DataWithAllTemplate>>(
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
    );
  }

  Widget _buildListItem(BuildContext context, DataWithAllTemplate data) {
    final otpEntry = OTPEntry.fromUri(Uri.parse(data.dataValue!.value));
    return Dismissible(
      key: Key('totp-${data.templateDetail.id}'),
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
              content: Text("Are you sure you want to delete ${otpEntry.siteName}?"),
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
      onDismissed: (direction) {
        var msg = '${otpEntry.siteName} deleted';
        setState(() {
          widget.vault.transaction(() async => widget.vault.deleteTemplate(data.template));
        });
        snackInfo(context, msg);
      },
      child: OTPTile(entry: otpEntry,
        iconColor: data.template.color,
        iconName: data.template.icon,),
    );
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
          vault: widget.vault,
          onItemSelected: (Template item) {
            // Handle the selected item
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddSecretScreen(template: item, vault: widget.vault,)));
          },
          onLoad: widget.vault.getActiveTokenTemplates,
        );
      },
    );
  }
}


class OTPKeyEnterDialog extends StatefulWidget {
  final Function(OTPEntry entry) onEntryAdded;

  const OTPKeyEnterDialog({super.key, required this.onEntryAdded});

  @override
  _OTPKeyEnterDialogState createState() => _OTPKeyEnterDialogState();
}

class _OTPKeyEnterDialogState extends State<OTPKeyEnterDialog> {
  final _accountNameController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _accountNameFocus = FocusNode();
  final _secretKeyFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Set focus to the first field when the dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_accountNameFocus);
    });
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _secretKeyController.dispose();
    _accountNameFocus.dispose();
    _secretKeyFocus.dispose();
    super.dispose();
  }

  void _handleAdd() {
    // Here you would typically handle the "Add" action
    if (_accountNameController.text.isEmpty) {
      snackError(context, "Account name cannot be empty");
      _accountNameFocus.requestFocus();
      return;
    }

    if (_secretKeyController.text.isEmpty) {
      snackError(context, "Secret key cannot be empty");
      _secretKeyFocus.requestFocus();
      return;
    }

    try {
      var otp = OTPEntry(
        siteName: _accountNameController.text,
        secret: _secretKeyController.text,
      );
      otp.generateOTP();
      Navigator.of(context).pop();
      widget.onEntryAdded(otp);
    } catch (e) {
      // Handle error
      snackError(context, "Incorrect secret key");
      _secretKeyFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter OTP Key'),
      content:
      SizedBox(
        width: 300,
        child:
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _accountNameController,
            focusNode: _accountNameFocus,
            decoration: const InputDecoration(labelText: 'Account name'),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_secretKeyFocus);
            },
          ),
          TextField(
            controller: _secretKeyController,
            focusNode: _secretKeyFocus,
            decoration: const InputDecoration(labelText: 'Secret key'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleAdd(),
          ),
        ],
      ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _handleAdd,
          child: const Text('Add'),
        ),
      ],
    );
  }
}