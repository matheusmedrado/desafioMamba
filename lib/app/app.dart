import 'package:flutter/material.dart';

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
      home: const AuthGate(),
    );
  }
}
