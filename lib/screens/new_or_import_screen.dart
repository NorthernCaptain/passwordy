import 'package:flutter/material.dart';
import 'package:passwordy/screens/login_screen.dart';
import 'package:passwordy/screens/master_password.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/service/sync/sync_manager.dart';
import 'package:passwordy/service/utils.dart';

class NewOrImportScreen extends StatelessWidget {
  const NewOrImportScreen({Key? key}) : super(key: key);

  Future<void> _importVault(BuildContext context) async {
    // Ensure signed in
    bool isSignedIn = await SyncManager.instance.ensureSignedIn(useSilent: false);
    if (!isSignedIn) {
      snackError(context, 'Failed to sign in. Please try again.');
      return;
    }

    // Show loading bottom sheet
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Importing vault...'),
              ],
            ),
          ),
        );
      },
    );

    // Download main vault
    bool downloadSuccess = await SyncManager.instance.downloadVault();

    // Close loading bottom sheet
    Navigator.of(context).pop();

    // Show result message
    if (downloadSuccess) {
      snackInfo(context, 'Vault imported successfully!');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      snackError(context, 'Failed to import vault. Make sure you have a valid backup in your cloud.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/img/logo.png',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 64),
            const Text(
              'Create a new empty vault or import an existing one from your Google Drive.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _newVault(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Create New Vault'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _importVault(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.cloud_download),
                label: const Text('Import from my Cloud'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _newVault(BuildContext context) async {
    await Vault.resetDB();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MasterPasswordScreen(),
      ),
    );
  }
}