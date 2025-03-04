import 'package:flutter/material.dart';
import 'package:my_expenses/screens/home_page.dart';

import 'db/offline_db_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineDbProvider.provider.initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ Correct null safety

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
