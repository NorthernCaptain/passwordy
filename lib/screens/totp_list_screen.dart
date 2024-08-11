import 'package:flutter/material.dart';
import 'dart:async';
import 'package:passwordy/service/totp.dart';
import 'package:passwordy/screens/qr_code_reader.dart';
import 'package:passwordy/service/utils.dart';
import 'package:passwordy/widgets/add_options_state.dart';
import 'package:passwordy/widgets/empty_state.dart';
import 'package:passwordy/widgets/otp_tile.dart';

class AuthenticatorScreen extends AddOptionsWidget {
  AuthenticatorScreen({Key? key}) : super(key: key);

  @override
  _AuthenticatorScreenState createState() => _AuthenticatorScreenState();
}

class _AuthenticatorScreenState
    extends State<AuthenticatorScreen> with KeyedAddOptionsState<AuthenticatorScreen> {
  List<OTPEntry> totpEntries = [
    OTPEntry(siteName: 'Google', secret: 'JBSWY3DPEHPK3PXP'),
    OTPEntry(siteName: 'GitHub', secret: 'JBSWY3DPEHPK3PXQ'),
    // Add more entries as needed
  ];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // This will rebuild the widget every second to update the TOTP codes
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
      body: totpEntries.isEmpty ? Column(
        children: [Expanded(child: EmptyState())]) :
      ListView.builder(
        itemCount: totpEntries.length,
        itemBuilder: (context, index) {
          return _buildListItem(context, index);
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Dismissible(
      key: Key('totp-$index'),
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
              content: Text("Are you sure you want to delete ${totpEntries[index].siteName}?"),
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
        var msg = totpEntries[index].siteName + ' deleted';
        setState(() {
          totpEntries.removeAt(index);
        });
        snackInfo(context, msg);
      },
      child: OTPTile(entry: totpEntries[index]),
    );
  }

  @override
  void showAddOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Scan QR code'),
                    onTap: () {
                      Navigator.pop(context);
                      _scanQRCode();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.keyboard),
                    title: const Text('Enter key manually'),
                    onTap: () {
                      Navigator.pop(context);
                      _showManualEntryDialog();
                    },
                  ),
                ],
              ),
            )
        );
      },
    );
  }

  void _scanQRCode() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          QRViewReader(onQRScanned: (entry) => {
            _addOTPEntry(entry)
          })
      ),
    );
  }

  void _addOTPEntry(OTPEntry entry) {
    setState(() {
      totpEntries.add(entry);
    });
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => OTPKeyEnterDialog(onEntryAdded: (entry) => _addOTPEntry(entry)),
    );
  }
}


class OTPKeyEnterDialog extends StatefulWidget {
  final Function(OTPEntry entry) onEntryAdded;

  const OTPKeyEnterDialog({Key? key, required this.onEntryAdded}) : super(key: key);

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