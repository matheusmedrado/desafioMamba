import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'auth_gate.dart';
import 'theme.dart';

class MambaApp extends StatelessWidget {
  const MambaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mamba Fast Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildMambaTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supported) {
        final resolved = basicLocaleListResolution([?locale], supported);
        // Dates and numbers follow the language of the interface.
        Intl.defaultLocale = resolved.toLanguageTag();
        return resolved;
      },
      home: const AuthGate(),
    );
  }
}
