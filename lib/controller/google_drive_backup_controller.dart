import 'dart:io';
import 'dart:convert';
import 'package:billing_application/data/database_helper.dart';
import 'package:billing_application/utils/toasts.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

final googleClientId = dotenv.env['GOOGLE_CLIENT_ID'];
final googleClientSecret = dotenv.env['GOOGLE_CLIENT_SECRET'];

/// OAuth Credentials
final clientId = ClientId(
  googleClientId!,
  googleClientSecret,
);

/// Scopes (Includes Drive and Email Access)
final scopes = [
  drive.DriveApi.driveFileScope,
  "https://www.googleapis.com/auth/userinfo.email"
];

/// Local Storage for Credentials
final credentialsFile = File('credentials.json');

/// Exception to indicate that the upload was cancelled.
class UploadCancelledException implements Exception {
  final String message;
  UploadCancelledException([this.message = "Upload cancelled by user"]);
  @override
  String toString() => message;
}

class BackupController extends GetxController {
  var isBackingUp = false.obs;
  var lastBackup = ''.obs;
  var backupEmail = ''.obs;

  // Progress Tracking
  var uploadProgress = 0.0.obs;
  var uploadedBytes = 0.obs;
  var totalBytes = 0.obs;
  var isCancelled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLastBackup();
    _initializeBackupEmail();
  }

  //   /// Initialize and fetch authenticated email.
  Future<void> _initializeBackupEmail() async {
    final storedCredentials = await loadCredentials();
    if (storedCredentials == null) return; // Don't prompt login if no credentials

    try {
      final client = authenticatedClient(http.Client(), storedCredentials);
      final email = await getUserEmail(client);
      if (email != null) backupEmail.value = email;
      client.close();
    } catch (e) {
      debugPrint("Stored credentials are invalid, requiring re-authentication: $e");
    }
  }


  Future<void> _loadLastBackup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastBackup.value = prefs.getString('lastBackup') ?? '';
  }

  Future<void> _saveLastBackup(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastBackup', date);
  }

  //   /// Open authentication URL in browser.
  Future<void> openAuthUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint("Could not launch $url");
    }
  }

  /// **LOGIN Function (Does NOT trigger backup)**
  Future<void> login() async {
    try {
      final client = await getAuthenticatedClient();
      final email = await getUserEmail(client);
      if (email != null) {
        backupEmail.value = email;
        debugPrint("Authenticated as: $email");
      }
      client.close();
    } catch (e) {
      debugPrint("Login failed: $e");
      errorToast("Please try again.", "Authentication Failed");
    }
  }

  /// **Clears stored credentials & logs out user**
  Future<void> clearCredentials() async {
    if (await credentialsFile.exists()) {
      await credentialsFile.delete();
      backupEmail.value = '';
      debugPrint("Credentials cleared.");
    }
  }

  /// **BACKUP Function (Runs only if already logged in)**
  Future<void> performBackup() async {
    if (backupEmail.value.isEmpty) {
      debugPrint("User not logged in. Backup aborted.");
      errorToast("Please login before backing up.", "Login Required");
      return;
    }

    try {
      isBackingUp.value = true;
      isCancelled.value = false; // Reset cancel state
      uploadProgress.value = 0.0;
      uploadedBytes.value = 0;
      totalBytes.value = 0;

      final client = await getAuthenticatedClient();
      final db = await DatabaseHelper.instance.database;
      final dbPath = db.path;

      await deleteOldBackup(client);
      await uploadDatabaseToDrive(client, dbPath);

      final now = DateTime.now().toString();
      lastBackup.value = now;
      await _saveLastBackup(now);
      client.close();

      successToast("Your database was backed up successfully.", "Backup Success");
    } on UploadCancelledException {
      debugPrint("Backup was cancelled.");
    } catch (e) {
      if (e.toString().contains("insufficient_scope")){
        debugPrint("Insufficient permission: $e");
        errorToast("Permission denied. Please logout and login again to grant access.",
            "Google Drive Permission Error");
      }else {
        debugPrint("Error during file upload: $e");
        errorToast("An error occurred during backup.", "Backup Failed");
      }
    } finally {
      isBackingUp.value = false;
    }
  }
}


/// **Get Authenticated Client with URL Launcher**
Future<http.Client> getAuthenticatedClient() async {
  AccessCredentials? storedCredentials = await loadCredentials();

  if (storedCredentials != null) {
    try {
      return authenticatedClient(http.Client(), storedCredentials);
    } catch (e) {
      debugPrint("Stored credentials failed: $e");
    }
  }

  return clientViaUserConsent(clientId, scopes, (authUrl) async {
    debugPrint("Open this URL for authentication: $authUrl");
    await Get.find<BackupController>().openAuthUrl(authUrl);
  }).then((client) async {
    await saveCredentials(client.credentials);
    return client;
  });
}

/// Load Stored OAuth Credentials.
Future<AccessCredentials?> loadCredentials() async {
  if (await credentialsFile.exists()) {
    try {
      final jsonData = json.decode(await credentialsFile.readAsString());
      return AccessCredentials(
        AccessToken(
          jsonData['type'],
          jsonData['data'],
          DateTime.parse(jsonData['expiry']),
        ),
        jsonData['refreshToken'],
        scopes,
      );
    } catch (e) {
      debugPrint("Error reading credentials: $e");
    }
  }
  return null;
}

/// Save OAuth Credentials.
Future<void> saveCredentials(AccessCredentials credentials) async {
  final jsonData = {
    'type': credentials.accessToken.type,
    'data': credentials.accessToken.data,
    'expiry': credentials.accessToken.expiry.toIso8601String(),
    'refreshToken': credentials.refreshToken,
  };
  await credentialsFile.writeAsString(json.encode(jsonData));
}

/// Fetch authenticated user email.
Future<String?> getUserEmail(http.Client client) async {
  try {
    final response =
    await client.get(Uri.parse("https://www.googleapis.com/oauth2/v3/userinfo"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["email"];
    }
  } catch (e) {
    debugPrint("Error fetching user email: $e");
  }
  return null;
}

/// **Deletes the previous backup before uploading a new one.**
Future<void> deleteOldBackup(http.Client client) async {
  try {
    final driveApi = drive.DriveApi(client);
    final fileList = await driveApi.files.list(q: "name='invoicely-backup.db'");

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      for (var file in fileList.files!) {
        await driveApi.files.delete(file.id!);
        debugPrint("Deleted old backup: ${file.id}");
      }
    }
  } catch (e) {
    debugPrint("Error deleting old backups: $e");
  }
}

/// **Uploads the database file to Google Drive with progress tracking.**
Future<void> uploadDatabaseToDrive(http.Client client, String dbFilePath) async {
  try {
    final driveApi = drive.DriveApi(client);
    final fileToUpload = File(dbFilePath);
    final totalFileBytes = await fileToUpload.length();
    final controller = Get.find<BackupController>();
    controller.totalBytes.value = totalFileBytes;
    controller.uploadedBytes.value = 0;

    // Create the progress stream.
    final progressStream =
    createProgressStream(fileToUpload, totalFileBytes, (bytesRead) {
      controller.uploadedBytes.value = bytesRead;
      controller.uploadProgress.value = bytesRead / totalFileBytes;
      debugPrint("Uploaded: $bytesRead / $totalFileBytes (${(bytesRead / totalFileBytes * 100).toStringAsFixed(2)}%)");
    });

    final media = drive.Media(progressStream, totalFileBytes);
    final driveFile = drive.File()..name = 'invoicely-backup.db';

    final result = await driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );

    debugPrint("File uploaded successfully! File ID: ${result.id}");
  } catch (e) {
    if (e is UploadCancelledException) {
      debugPrint("Upload cancelled by user.");
    } else if (e.toString().contains("insufficient_scope")){
      debugPrint("Insufficient permission: $e");
      errorToast("Permission denied. Please logout and login again to grant access.",
          "Google Drive Permission Error");
    }else {
      debugPrint("Error during file upload: $e");
      errorToast("Failed to upload backup on google drive");
    }
    rethrow;
  }
}

Stream<List<int>> createProgressStream(
    File file, int totalFileBytes, void Function(int bytesRead) onProgress) async* {
  int totalBytesRead = 0;
  // Listen to file stream.
  await for (var chunk in file.openRead()) {
    totalBytesRead += chunk.length;
    onProgress(totalBytesRead);
    // Check if the user cancelled the upload.
    if (Get.find<BackupController>().isCancelled.value) {
      throw UploadCancelledException();
    }
    yield chunk;
  }
}
