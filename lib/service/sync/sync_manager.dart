import 'package:passwordy/service/log.dart';
import 'package:passwordy/service/sync/drive_service.dart';

class SignInException implements Exception {
  final String message;

  SignInException(this.message);
}

class SyncManager {
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
}