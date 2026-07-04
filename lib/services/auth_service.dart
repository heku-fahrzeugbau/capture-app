import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  GoogleSignInAccount? _currentUser;
  String? _accessToken;
  String? _selectedFolderID;
  String? _selectedFolderName;

  bool get isAuthenticated => _currentUser != null && _accessToken != null;
  String? get userEmail => _currentUser?.email;
  String? get accessToken => _accessToken;
  String? get selectedFolderID => _selectedFolderID;
  String? get selectedFolderName => _selectedFolderName;

  AuthService() {
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      _currentUser = account;
      if (account != null) {
        final auth = await account.authentication;
        _accessToken = auth.accessToken;
      } else {
        _accessToken = null;
      }
      notifyListeners();
    });
    _googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        _accessToken = auth.accessToken;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Sign in failed: $e');
    }
  }

  void setSelectedFolder(String folderId, String folderName) {
    _selectedFolderID = folderId;
    _selectedFolderName = folderName;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _accessToken = null;
    _selectedFolderID = null;
    _selectedFolderName = null;
    notifyListeners();
  }
}
