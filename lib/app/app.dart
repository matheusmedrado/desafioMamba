import 'package:flutter/material.dart';

import 'theme.dart';

class MambaApp extends StatelessWidget {
  const MambaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mamba Fast Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildMambaTheme(),
      home: const _PlaceholderHome(),
    );
  }
}

/// Temporary entry screen. The login flow replaces it in the next issue.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/mamba-wordmark.webp',
                height: 32,
                semanticLabel: 'Mamba',
              ),
              const SizedBox(height: 8),
              Text(
                'FAST TRACKER',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(letterSpacing: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
