import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:passwordy/service/log.dart';
import 'package:passwordy/service/sync/drive_service.dart';

class GoogleDriveServiceImpl implements DriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  drive.DriveApi? _driveApi;

  @override
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      final auth = await account.authentication;
      final client = GoogleAuthClient(auth.accessToken!);
      _driveApi = drive.DriveApi(client);
      return true;
    } catch (error) {
      lg?.e('Error signing in: $error');
      return false;
    }
  }

  @override
  Future<bool> silentSignIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return false;

      final auth = await account.authentication;
      final client = GoogleAuthClient(auth.accessToken!);
      _driveApi = drive.DriveApi(client);
      return true;
    } catch (error) {
      lg?.e('Error signing in silently: $error');
      return false;
    }
  }

  @override
  Future<String> getFile(String fileId, String localPath) async {
    if (_driveApi == null) throw Exception('Not signed in');

    try {
      final driveFile = await _driveApi!.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final Stream<List<int>> stream = driveFile.stream;
      final File file = File(localPath);
      final sink = file.openWrite();

      await stream.pipe(sink);
      await sink.flush();
      await sink.close();

      return localPath;
    } catch (e) {
      lg?.e('Error downloading file: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteFile(String fileId) async {
    if (_driveApi == null) throw Exception('Not signed in');

    try {
      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      lg?.e('Error deleting file: $e');
      return false;
    }
  }

  @override
  Future<List<DriveFile>> listFiles(String folderPath) async {
    if (_driveApi == null) throw Exception('Not signed in');

    try {
      String? folderId = await _getFolderByPath(folderPath);
      if (folderId == null) {
        // Folder doesn't exist, return an empty list
        return [];
      }

      final fileList = await _driveApi!.files.list(
          q: "'$folderId' in parents and trashed=false",
          $fields: "files(id, name, mimeType, modifiedTime, size)"
      );

      return fileList.files?.map((file) => DriveFile(
          id: file.id!,
          name: file.name!,
          mimeType: file.mimeType!,
          modifiedTime: file.modifiedTime,
          size: file.size != null ? int.tryParse(file.size!) : null
      )).toList() ?? [];
    } catch (e) {
      lg?.e('Error listing files: $e');
      rethrow;
    }
  }

  Future<String?> _getFolderByPath(String folderPath) async {
    List<String> folderNames = folderPath.split('/').where((s) => s.isNotEmpty).toList();
    String? parentId;

    for (String folderName in folderNames) {
      String? folderId = await _findFolder(folderName, parentId);
      if (folderId == null) {
        // If any folder in the path doesn't exist, return null
        return null;
      }
      parentId = folderId;
    }

    return parentId;
  }

  Future<String?> _findFolder(String folderName, String? parentId) async {
    String query = "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
    if (parentId != null) {
      query += " and '$parentId' in parents";
    }

    final folderList = await _driveApi!.files.list(q: query);

    if (folderList.files != null && folderList.files!.isNotEmpty) {
      return folderList.files!.first.id;
    }

    return null; // Folder not found
  }

  Future<String> _getOrCreateFolderByPath(String folderPath) async {
    List<String> folderNames = folderPath.split('/').where((s) => s.isNotEmpty).toList();
    String? parentId;
    String lastFolderId = '';

    for (String folderName in folderNames) {
      lastFolderId = await _findOrCreateFolder(folderName, parentId);
      parentId = lastFolderId;
    }

    return lastFolderId;
  }

  Future<String> _findOrCreateFolder(String folderName, String? parentId) async {
    String? existingFolderId = await _findFolder(folderName, parentId);
    if (existingFolderId != null) {
      return existingFolderId;
    }

    // Folder doesn't exist, create it
    final folderMetadata = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    if (parentId != null) {
      folderMetadata.parents = [parentId];
    }

    final folder = await _driveApi!.files.create(folderMetadata);
    return folder.id!;
  }

  @override
  Future<String> createFolder(String folderPath) async {
    if (_driveApi == null) throw Exception('Not signed in');
    return await _getOrCreateFolderByPath(folderPath);
  }

  @override
  Future<String> putFile(String filePath, String fileName, String folderPath) async {
    if (_driveApi == null) throw Exception('Not signed in');

    final file = File(filePath);
    final media = drive.Media(file.openRead(), file.lengthSync());

    String folderId = await _getOrCreateFolderByPath(folderPath);

    final driveFile = drive.File()
      ..name = fileName
      ..parents = [folderId];

    try {
      final result = await _driveApi!.files.create(driveFile, uploadMedia: media);
      return result.id!;
    } catch (e) {
      lg?.e('Error uploading file: $e');
      rethrow;
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}