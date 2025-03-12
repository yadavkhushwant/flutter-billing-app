import 'dart:convert';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/src/client.dart';
import 'package:path_provider/path_provider.dart';

class GoogleDriveService {
  static const String backupFileName = "database_backup.db";

  late GoogleSignInAccount? _currentUser;
  late drive.DriveApi? _driveApi;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  Future<void> authenticate() async {
    _currentUser = await _googleSignIn.signIn();
    if (_currentUser == null) {
      throw Exception("Google Sign-In failed");
    }

    final googleAuth = await _currentUser!.authentication;
    final authClient = auth.authenticatedClient(
      HttpClient() as Client,
      auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          googleAuth.accessToken!,
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        googleAuth.accessToken,
        [drive.DriveApi.driveFileScope],
      ),
    );

    _driveApi = drive.DriveApi(authClient);
  }

  Future<void> backupDatabaseToGoogleDrive() async {
    if (_driveApi == null) {
      throw Exception("Google Drive API not initialized");
    }

    final dbPath = await getDatabasePath();
    final dbFile = File(dbPath);

    // Check if the backup file already exists
    final existingFileId = await _findBackupFileId();
    if (existingFileId != null) {
      // Delete the old backup file
      await _driveApi!.files.delete(existingFileId);
    }

    // Upload the new backup
    final driveFile = drive.File();
    driveFile.name = backupFileName;

    final media = drive.Media(dbFile.openRead(), dbFile.lengthSync());
    await _driveApi!.files.create(driveFile, uploadMedia: media);
    print("Database backup uploaded to Google Drive");
  }

  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/your_database.db";
  }

  Future<String?> _findBackupFileId() async {
    final response = await _driveApi!.files.list(q: "name='$backupFileName'");
    if (response.files != null && response.files!.isNotEmpty) {
      return response.files!.first.id;
    }
    return null;
  }

  // Future<void> restoreDatabaseFromGoogleDrive() async {
  //   if (_driveApi == null) {
  //     throw Exception("Google Drive API not initialized");
  //   }
  //
  //   final fileId = await _findBackupFileId();
  //   if (fileId == null) {
  //     throw Exception("No backup file found on Google Drive");
  //   }
  //
  //   final dbPath = await getDatabasePath();
  //   final dbFile = File(dbPath);
  //
  //   final mediaStream = await _driveApi!.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia);
  //   final mediaBytes = <int>[];
  //   mediaStream.stream.listen((data) {
  //     mediaBytes.addAll(data);
  //   }, onDone: () async {
  //     await dbFile.writeAsBytes(mediaBytes);
  //     print("Database restored successfully");
  //   });
  // }


}
