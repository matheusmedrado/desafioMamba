import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/app/app.dart';
import 'package:mamba_fast_tracker/core/database.dart';
import 'package:mamba_fast_tracker/features/auth/data/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/data/profile_photo_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/data/fasting_notification_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../fasting/fake_fasting_notification_service.dart';
import 'fake_auth_repository.dart';

/// Returns a picture the user chose, or nothing when they cancel.
class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker(this.file);

  File? file;
  var pickCount = 0;

  @override
  Future<File?> pickFromGallery() async {
    pickCount++;
    return file;
  }
}

/// Keeps the photo in memory, since a widget test does not run file work.
class FakeProfilePhotoRepository implements ProfilePhotoRepository {
  FakeProfilePhotoRepository(this.userId);

  @override
  final String userId;

  @override
  Directory? get directory => null;

  File? photo;

  @override
  Future<File?> load() async => photo;

  @override
  Future<File> save(File source) async {
    photo = source;
    return source;
  }

  @override
  Future<void> clear() async {
    photo = null;
  }
}

void main() {
  setUpAll(sqfliteFfiInit);

  // A one pixel PNG, so the widget can actually decode the photo.
  final pixel = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  );

  late Database database;
  late FakeAuthRepository accounts;
  late FakePhotoPicker picker;
  late FakeProfilePhotoRepository photos;
  late Directory photoDirectory;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    PackageInfo.setMockInitialValues(
      appName: 'Mamba Fast Tracker',
      packageName: 'com.matheusmedrado.mamba_fast_tracker',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    accounts = FakeAuthRepository()
      ..addAccount('user@example.com', 'password1');
    database = await AppDatabase.open(
      databaseFactoryFfiNoIsolate,
      inMemoryDatabasePath,
    );
    photoDirectory = await Directory.systemTemp.createTemp('mamba_photo');
    final chosen = File('${photoDirectory.path}/chosen.png')
      ..writeAsBytesSync(pixel);
    picker = FakePhotoPicker(chosen);
    photos = FakeProfilePhotoRepository('uid-user@example.com');
  });

  tearDown(() async {
    await database.close();
    await photoDirectory.delete(recursive: true);
  });

  Future<void> openSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2430);
    tester.view.devicePixelRatio = 2.7;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(accounts),
          databaseProvider.overrideWith((ref) => database),
          fastingNotificationServiceProvider.overrideWithValue(
            RecordingFastingNotificationService(),
          ),
          photoPickerProvider.overrideWithValue(picker),
          profilePhotoRepositoryProvider.overrideWithValue(photos),
        ],
        child: const MambaApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the account, the language, and the app version', (
    tester,
  ) async {
    await openSettings(tester);

    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('Add your name'), findsOneWidget);
    expect(find.text('Follows your device'), findsOneWidget);
    expect(find.text('1.0.0 (1)'), findsOneWidget);
  });

  testWidgets('saving a name shows it on the profile', (tester) async {
    await openSettings(tester);

    await tester.tap(find.text('Change name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Matheus');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name updated'), findsOneWidget);
    expect(find.text('Matheus'), findsWidgets);
    expect(find.text('Add your name'), findsNothing);
  });

  testWidgets('a chosen photo is kept, and removing it clears it', (
    tester,
  ) async {
    await openSettings(tester);

    await tester.tap(find.text('Change photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    expect(picker.pickCount, 1);
    expect(find.text('Photo updated'), findsOneWidget);
    expect(photos.photo, isNotNull);

    await tester.tap(find.text('Change photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove photo'));
    await tester.pumpAndSettle();

    expect(find.text('Photo removed'), findsOneWidget);
    expect(photos.photo, isNull);
  });
}
