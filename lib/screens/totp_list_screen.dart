import 'package:flutter/material.dart';
import 'dart:async';
import 'package:passwordy/service/totp.dart';
import 'package:passwordy/screens/qr_code_reader.dart';

class AuthenticatorScreen extends StatefulWidget {
  const AuthenticatorScreen({super.key});

  @override
  _AuthenticatorScreenState createState() => _AuthenticatorScreenState();
}

class _AuthenticatorScreenState extends State<AuthenticatorScreen> {
  List<TOTPEntry> totpEntries = [
    TOTPEntry(siteName: 'Google', secret: 'JBSWY3DPEHPK3PXP'),
    TOTPEntry(siteName: 'GitHub', secret: 'JBSWY3DPEHPK3PXQ'),
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
            onPressed: _showAddOptions,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: totpEntries.length,
        itemBuilder: (context, index) {
          return _buildTOTPTile(totpEntries[index]);
        },
      ),
    );
  }

  Widget _buildTOTPTile(TOTPEntry entry) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(entry.siteName[0]),
      ),
      title: Text(entry.siteName),
      subtitle: Text(
        entry.generateTOTP(),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
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
        );
      },
    );
  }

  void _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRViewReader()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        totpEntries.add(TOTPEntry(siteName: result['siteName']!, secret: result['secret']!));
      });
    }
  }

  void _processQRResult(String result) {
    // Example QR code format: otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example
    Uri uri = Uri.parse(result);
    if (uri.scheme == 'otpauth' && uri.host == 'totp') {
      String siteName = uri.queryParameters['issuer'] ?? 'Unknown';
      String secret = uri.queryParameters['secret'] ?? '';

      if (secret.isNotEmpty) {
        setState(() {
          totpEntries.add(TOTPEntry(siteName: siteName, secret: secret));
        });
      }
    } else {
      // Show an error message for invalid QR code
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid QR code format')),
      );
    }
  }

  void _showManualEntryDialog() {
    String accountName = '';
    String secretKey = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter TOTP Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Account Name'),
                onChanged: (value) {
                  accountName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Secret Key'),
                onChanged: (value) {
                  secretKey = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                if (accountName.isNotEmpty && secretKey.isNotEmpty) {
                  setState(() {
                    totpEntries.add(TOTPEntry(siteName: accountName, secret: secretKey));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
