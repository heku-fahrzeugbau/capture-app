import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/sync_engine.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CaptureApp());
}

class CaptureApp extends StatelessWidget {
  const CaptureApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => StorageService()),
        ChangeNotifierProxyProvider<AuthService, SyncEngine>(
          create: (_) => SyncEngine(
            authService: Provider.of<AuthService>(_, listen: false),
            storageService: Provider.of<StorageService>(_, listen: false),
          ),
          update: (_, authService, syncEngine) => syncEngine ?? SyncEngine(
            authService: authService,
            storageService: Provider.of<StorageService>(_, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Quick Notes App',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF000000),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF000000),
            elevation: 0,
          ),
        ),
        home: Consumer<AuthService>(
          builder: (_, authService, __) {
            return authService.isAuthenticated ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
