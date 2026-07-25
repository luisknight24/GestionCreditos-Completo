import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'config/router/app_router.dart';
import 'providers/register_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:http/http.dart' as http;

void _warmupServer() {
  try {
    http.get(Uri.parse('https://gestioncreditos-backend.onrender.com/api/Rol/Lista')).then((res) {
      debugPrint('🔥 [WARMUP] Servidor en línea (Status: ${res.statusCode})');
    }).catchError((e) {
      debugPrint('⚠️ [WARMUP] Error al calentar servidor: $e');
    });
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _warmupServer();
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase init skipped: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos la app en el Provider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'CellCompay',
        theme: AppTheme().getTheme(),
        routerConfig: appRouter,
        builder: (context, child) {
          if (kIsWeb) {
            return Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: child ?? const SizedBox(),
                ),
              ),
            );
          }
          return child ?? const SizedBox();
        },
      ),
    );
  }
}