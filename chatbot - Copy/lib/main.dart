import 'package:chonoes/backend/saving_data.dart';
import 'package:chonoes/bloc/bloc.dart';
import 'package:chonoes/pages/homepage_1.dart';
import 'package:chonoes/pages/splash_screen.dart';
import 'package:chonoes/secrets.dart';
import 'package:chonoes/system/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(boxName);
  await Hive.openBox(userData);

  // Validate API key from secrets.dart
  if (APIKEY.isEmpty) {
    print('ERROR: API key is empty! Please check secrets.dart');
  } else {
    print(
        'API key loaded: ${APIKEY.substring(0, 10)}... (length: ${APIKEY.length})');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MessageBloc(),
        child: const MaterialApp(
            debugShowCheckedModeBanner: false, home: SplashScreen()));
  }
}
