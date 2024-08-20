
import 'package:passwordy/service/sync/google_drive_service.dart';

enum DriveServiceType {
  googleDrive,
  icloud, // Not implemented
  dropbox, // Not implemented
  oneDrive // Not implemented
}

abstract class DriveService {
  Future<bool> signIn();
  Future<bool> silentSignIn();
  Future<String> putFile(String filePath, String fileName, String folderName);
  Future<String> getFile(String fileId, String localPath);
  Future<bool> deleteFile(String fileId);
  Future<List<DriveFile>> listFiles(String folderName);
  Future<String> createFolder(String folderName);

  factory DriveService(DriveServiceType type) {
    switch (type) {
      case DriveServiceType.googleDrive:
        return GoogleDriveServiceImpl();
      case DriveServiceType.icloud:
        throw UnimplementedError();
      case DriveServiceType.dropbox:
        throw UnimplementedError();
      case DriveServiceType.oneDrive:
        throw UnimplementedError();
    }
  }
}

class DriveFile {
  final String id;
  final String name;
  final String mimeType;
  final DateTime? modifiedTime;
  final int? size;

  DriveFile({
    required this.id,
    required this.name,
    required this.mimeType,
    this.modifiedTime,
    this.size
  });
}