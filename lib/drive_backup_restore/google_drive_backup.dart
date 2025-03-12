import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class GoogleDriveBackup {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  Future<Map<String, String>?> _getAuthHeaders() async {
    final account = await _googleSignIn.signIn();
    return account?.authHeaders;
  }

  /// Custom HTTP client that adds auth headers to every request.
  http.Client _getAuthenticatedClient(Map<String, String> headers) {
    return _AuthClient(headers);
  }

  /// Uploads the given file (at filePath) to Google Drive.
  Future<String?> uploadDatabase(String filePath) async {
    final headers = await _getAuthHeaders();
    if (headers == null) {
      print('Google sign-in failed.');
      return null;
    }
    final client = _getAuthenticatedClient(headers);
    final driveApi = ga.DriveApi(client);

    // Prepare the file metadata.
    var dbFileName = path.basename(filePath);
    final driveFile = ga.File()
      ..name = dbFileName
    // Optionally, uncomment the following to store in the appDataFolder.
    // ..parents = ['appDataFolder'];

        ;

    final file = File(filePath);
    final media = ga.Media(file.openRead(), file.lengthSync());

    try {
      // Creates a new file on Google Drive.
      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );
      print("Upload successful! File ID: ${response.id}");
      return response.id;
    } catch (error) {
      print("Error during upload: $error");
      return null;
    }
  }
}

/// A simple HTTP client that adds authentication headers.
class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
