import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/note.dart';

class GoogleDriveService extends ChangeNotifier {
  final String _apiBaseUrl = 'https://www.googleapis.com/drive/v3';
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  Future<String> uploadNote(
    Note note,
    String authToken,
    String folderID,
  ) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_apiBaseUrl/files?uploadType=multipart');
      final boundary = '===============7330845974216740156==';

      final metadata = {
        'name': note.filename,
        'mimeType': 'text/markdown',
        'parents': [folderID],
      };

      final body = <int>[];
      body.addAll('--$boundary\r\n'.codeUnits);
      body.addAll('Content-Type: application/json; charset=UTF-8\r\n\r\n'.codeUnits);
      body.addAll(jsonEncode(metadata).codeUnits);
      body.addAll('\r\n--$boundary\r\n'.codeUnits);
      body.addAll('Content-Type: text/markdown\r\n\r\n'.codeUnits);
      body.addAll(note.markdownContent.codeUnits);
      body.addAll('\r\n--$boundary--\r\n'.codeUnits);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body);
        _isSyncing = false;
        notifyListeners();
        return result['id'];
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }
}
