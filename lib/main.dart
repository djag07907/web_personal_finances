import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/firebase_options.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/themes.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    return RepositoryProvider(
      create: (final _) => AuthRepository(),
      child: MaterialApp.router(
        routerConfig: appRoutes,
        title: 'Web Personal Finances',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          InternationalizationDelegate(
            suportedLocales: supportedLocales,
          ),
        ],
        supportedLocales: supportedLocales,
        localeResolutionCallback: (
          final ui.Locale? locale,
          final Iterable<ui.Locale> supportedLocales,
        ) {
          return Locale(
            locale?.languageCode ?? supportedLocales.first.languageCode,
          );
        },
      ),
    );
  }
}
