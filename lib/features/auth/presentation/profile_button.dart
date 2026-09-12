import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/profile_photo_repository.dart';
import 'settings_screen.dart';

/// Opens settings. Shows the profile photo once the user picks one.
class ProfileButton extends ConsumerWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(profilePhotoProvider).value;

    return Tooltip(
      message: AppLocalizations.of(context)!.settings,
      child: Material(
        color: MambaColors.surfaceElevated,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => openSettings(context),
          child: SizedBox.square(
            dimension: 44,
            child: photo == null
                ? const Center(child: MambaIcon(MambaIcons.settings))
                : Image.file(photo, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
