import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/screen_header.dart';
import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../fasting/data/fasting_notification_service.dart';
import '../data/profile_photo_repository.dart';
import '../domain/auth_failure.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'password_reset_sheet.dart';

/// Version of the installed build, such as "1.0.0 (1)".
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

Future<void> openSettings(BuildContext context) {
  return Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
}

/// Profile and app settings.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;
    final photo = ref.watch(profilePhotoProvider).value;
    final version = ref.watch(appVersionProvider).value ?? '—';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.settings, showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                children: [
                  _Profile(
                    name: user?.name,
                    email: user?.email ?? '',
                    photo: photo,
                    onChangePhoto: () => _changePhoto(context, ref),
                  ),
                  const SizedBox(height: 28),
                  _SectionTitle(l10n.accountSection),
                  _SettingsRow(
                    icon: MambaIcons.pencil,
                    label: l10n.changeName,
                    value: user?.name,
                    onTap: () => _changeName(context, ref, user?.name),
                  ),
                  const Divider(),
                  _SettingsRow(
                    icon: MambaIcons.logOut,
                    label: l10n.changePassword,
                    subtitle: l10n.changePasswordSubtitle,
                    onTap: () => showPasswordResetSheet(
                      context,
                      email: user?.email ?? '',
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SectionTitle(l10n.appSection),
                  _SettingsRow(
                    icon: MambaIcons.info,
                    label: l10n.language,
                    value: l10n.languageFollowsDevice,
                  ),
                  const Divider(),
                  _SettingsRow(
                    icon: MambaIcons.timer,
                    label: l10n.version,
                    value: version,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _logOut(context, ref),
                    icon: const MambaIcon(MambaIcons.logOut, size: 20),
                    label: Text(l10n.logOut),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logOut(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authControllerProvider.notifier);
    final notifications = ref.read(fastingNotificationServiceProvider);
    Navigator.of(context).pop();
    unawaited(auth.signOut().then((_) => notifications.cancelAll()));
  }

  Future<void> _changePhoto(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showModalBottomSheet<_PhotoChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const MambaIcon(MambaIcons.meals, size: 20),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.of(context).pop(_PhotoChoice.gallery),
            ),
            ListTile(
              leading: const MambaIcon(
                MambaIcons.trash,
                size: 20,
                color: MambaColors.danger,
              ),
              title: Text(l10n.removePhoto),
              onTap: () => Navigator.of(context).pop(_PhotoChoice.remove),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null) return;

    final repository = ref.read(profilePhotoRepositoryProvider);
    try {
      if (choice == _PhotoChoice.remove) {
        await repository.clear();
        _notify(messenger, l10n.photoRemoved);
      } else {
        final picked = await ref.read(photoPickerProvider).pickFromGallery();
        if (picked == null) return;
        await repository.save(picked);
        _notify(messenger, l10n.photoUpdated);
      }
      ref.invalidate(profilePhotoProvider);
    } catch (_) {
      _notify(messenger, l10n.couldNotSaveProfile);
    }
  }

  Future<void> _changeName(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NameSheet(initialName: current ?? ''),
    );
    if (name == null) return;

    try {
      await ref.read(authControllerProvider.notifier).updateName(name);
      _notify(messenger, l10n.nameUpdated);
    } on AuthFailure catch (failure) {
      _notify(messenger, authFailureMessage(l10n, failure));
    } catch (_) {
      _notify(messenger, l10n.couldNotSaveProfile);
    }
  }

  /// Replaces the previous message instead of queueing behind it.
  void _notify(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _PhotoChoice { gallery, remove }

class _Profile extends StatelessWidget {
  const _Profile({
    required this.name,
    required this.email,
    required this.photo,
    required this.onChangePhoto,
  });

  final String? name;
  final String email;
  final File? photo;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final source = (name?.isNotEmpty ?? false) ? name! : email;
    final initial = source.isEmpty ? '?' : source.substring(0, 1).toUpperCase();

    return Row(
      children: [
        Semantics(
          label: l10n.profilePhoto,
          button: true,
          child: InkWell(
            onTap: onChangePhoto,
            customBorder: const CircleBorder(),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: MambaColors.purpleTint,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: photo == null
                  ? Center(
                      child: Text(
                        initial,
                        style: textTheme.headlineMedium?.copyWith(fontSize: 26),
                      ),
                    )
                  : Image.file(photo!, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? l10n.addYourName,
                style: textTheme.titleMedium?.copyWith(
                  color: name == null
                      ? MambaColors.textSecondary
                      : MambaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(email, style: textTheme.bodySmall),
              const SizedBox(height: 6),
              TextButton(
                onPressed: onChangePhoto,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.changePhoto),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.96,
          color: MambaColors.textSecondary,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.value,
    this.onTap,
  });

  final MambaIcons icon;
  final String label;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MambaRadius.small),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            MambaIcon(icon, size: 18, color: MambaColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyLarge?.copyWith(fontSize: 15),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: textTheme.bodySmall),
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value!,
                  textAlign: TextAlign.end,
                  style: textTheme.bodySmall,
                ),
              ),
            ],
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const MambaIcon(
                MambaIcons.chevronRight,
                size: 18,
                color: MambaColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NameSheet extends StatefulWidget {
  const _NameSheet({required this.initialName});

  final String initialName;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.yourName, style: textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              maxLength: 40,
              onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
              decoration: InputDecoration(hintText: l10n.yourNameHint),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
