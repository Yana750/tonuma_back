import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:tonuma_back/screens/Provider/cart_provider.dart';
import 'package:tonuma_back/screens/Provider/favorite_provider.dart';
import 'package:tonuma_back/screens/Provider/product_provider.dart';
import 'package:tonuma_back/screens/splash_screen.dart';
import 'api/supabase_config.dart';

void main() async {
  await SupabaseConfig.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
    ],
    child: const MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}