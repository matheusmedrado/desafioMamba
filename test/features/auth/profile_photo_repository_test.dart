import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/auth/data/profile_photo_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  final pixel = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  );

  late Directory directory;
  late File chosen;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    directory = await Directory.systemTemp.createTemp('mamba_photo');
    chosen = File('${directory.path}/chosen.png')..writeAsBytesSync(pixel);
  });

  tearDown(() => directory.delete(recursive: true));

  ProfilePhotoRepository repositoryFor(String userId) {
    return ProfilePhotoRepository(
      SharedPreferencesAsync(),
      userId: userId,
      directory: directory,
    );
  }

  test('keeps a copy of the chosen photo, so the original can go', () async {
    final repository = repositoryFor('user-1');

    final saved = await repository.save(chosen);
    await chosen.delete();

    expect(saved.path, isNot(chosen.path));
    expect((await repository.load())?.path, saved.path);
  });

  test('each account keeps its own photo', () async {
    final mine = repositoryFor('user-1');
    final other = repositoryFor('user-2');

    await mine.save(chosen);

    expect(await mine.load(), isNotNull);
    expect(await other.load(), isNull);
  });

  test('removing the photo deletes the file', () async {
    final repository = repositoryFor('user-1');
    final saved = await repository.save(chosen);

    await repository.clear();

    expect(await repository.load(), isNull);
    expect(saved.existsSync(), isFalse);
  });

  test('a photo whose file disappeared is forgotten', () async {
    final repository = repositoryFor('user-1');
    final saved = await repository.save(chosen);

    await saved.delete();

    expect(await repository.load(), isNull);
  });
}
