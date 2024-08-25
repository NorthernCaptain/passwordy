
import 'dart:io';

import 'package:passwordy/service/log.dart';
import 'package:passwordy/service/sync/drive_service.dart';
import 'package:passwordy/service/db/db_vault.dart';

class SignInException implements Exception {
  final String message;

  SignInException(this.message);
}

class SyncManager {
  static const remoteFolder = "passwordy.backup";
  static const mainBackupFolder = "db";

  SyncManager._();

  static SyncManager instance = SyncManager._();

  final DriveService _driveService = DriveService(DriveServiceType.googleDrive);
  bool _isSignedIn = false;

  Future<bool> ensureSignedIn() async {
    if (_isSignedIn) return true;

    // Try silent sign-in first
    bool success = await _driveService.silentSignIn();

    if (!success) {
      // If silent sign-in fails, try regular sign-in
      success = await _driveService.signIn();
    }

    _isSignedIn = success;
    return success;
  }

  Future<void> performDriveOperation() async {
    if (await ensureSignedIn()) {
      // Perform your Google Drive operations here
      // For example:
      // await _driveService.listFiles('My Folder');
    } else {
      // Handle sign-in failure
      lg?.e('Failed to sign in to Google Drive');
      throw SignInException('Failed to sign in to remote drive');
    }
  }

  Future<T> guarded<T>(Future<T> Function(DriveService) caller) async {
    if (await ensureSignedIn()) {
      return caller(_driveService);
    } else {
      // Handle sign-in failure
      lg?.e('Failed to sign in to Google Drive');
      throw SignInException('Failed to sign in to remote drive');
    }
  }

  Future<void> signOut() async {
    // Implement sign out logic here
    _isSignedIn = false;
  }

  Future<bool> uploadBackup(String backupPath, {String dbName = Vault.masterDB, bool removeLocal = false}) async {
    final fileName = backupPath.split('/').last;
    const folderName = '$remoteFolder/$mainBackupFolder';
    return guarded((drive) async {
      try {
        // Upload the backup file to Google Drive
        final fileId = await drive.putFile(backupPath, fileName, folderName);
        final result = await drive.renameFileById(fileId, dbName, folderName, overwriteExisting: true);
        if(result != RenameResult.success) {
          lg?.e('Error renaming file: $result');
          return false;
        }
        lg?.i('Uploaded backup to Google Drive $folderName/$dbName');
        if (removeLocal) {
          // Delete the local backup file
          final file = File(backupPath);
          if(await file.exists()) {
            await file.delete();
          }
        }
        return true;
      } catch (e) {
        lg?.e('Error uploading backup: $e');
        return false;
      }
    });
  }
}