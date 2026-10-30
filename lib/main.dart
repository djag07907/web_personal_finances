import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:internationalization/internationalization.dart';
import 'package:provider/provider.dart';
import 'package:web_personal_finances/commons/bloc/app_auth_notifier.dart';
import 'package:web_personal_finances/commons/error/error_boundary.dart';
import 'package:web_personal_finances/commons/error/privacy_safe_logger.dart';
import 'package:web_personal_finances/commons/security/app_check_service.dart';
import 'package:web_personal_finances/firebase_options.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/themes.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup privacy-safe error handling and custom ErrorWidget
  FlutterError.onError = (final FlutterErrorDetails details) {
    PrivacySafeLogger.logError(
      details.exception,
      details.stack,
      'FlutterError: ${details.library ?? "framework"}',
    );
  };
  PlatformDispatcher.instance.onError =
      (final Object error, final StackTrace stack) {
        PrivacySafeLogger.logError(error, stack, 'PlatformDispatcher');
        return true;
      };
  ErrorWidget.builder = buildPrivacySafeErrorWidget;

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppCheckService.initialize();

  runApp(const ErrorBoundary(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final UserRepository _userRepository;
  late final AppAuthNotifier _authNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _authNotifier = AppAuthNotifier(userRepository: _userRepository);
    _router = buildAppRouter(_authNotifier);
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return MultiProvider(
      // ignore: always_specify_types
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (final _) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>.value(value: _userRepository),
        ChangeNotifierProvider<AppAuthNotifier>.value(value: _authNotifier),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        title: appName,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          InternationalizationDelegate(suportedLocales: supportedLocales),
        ],
        supportedLocales: supportedLocales,
        localeResolutionCallback:
            (
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
