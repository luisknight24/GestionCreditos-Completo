import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'config/router/app_router.dart';
import 'providers/register_provider.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async { // <--- Convertir a async
  WidgetsFlutterBinding.ensureInitialized(); // <--- Necesario para async en main
  await Firebase.initializeApp(); // <--- Iniciamos Firebase

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
      ),
    );
  }
}