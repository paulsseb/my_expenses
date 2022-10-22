import 'package:flutter/material.dart';
import 'package:my_expenses/screens/home_page.dart';

import 'db/offline_db_provider.dart';

void main() {
  OfflineDbProvider.provider.initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
