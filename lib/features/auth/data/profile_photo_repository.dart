import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences.dart';
import '../presentation/auth_controller.dart';

/// Picks an image from the device. An interface so tests can use a fake.
abstract interface class PhotoPicker {
  Future<File?> pickFromGallery();
}

class GalleryPhotoPicker implements PhotoPicker {
  const GalleryPhotoPicker();

  @override
  Future<File?> pickFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // A profile photo is shown small, so a large original is wasted space.
      maxWidth: 720,
      maxHeight: 720,
      imageQuality: 85,
    );
    return picked == null ? null : File(picked.path);
  }
}

/// Owns the profile photo of one user, kept as a file on the device.
class ProfilePhotoRepository {
  ProfilePhotoRepository(this._prefs, {this.userId = '', this.directory});

  static const baseKey = 'profile.photo';

  final SharedPreferencesAsync _prefs;
  final String userId;

  /// Where the photo is kept. The app's own files by default.
  final Directory? directory;

  String get _key => userKey(baseKey, userId);

  Future<File?> load() async {
    final path = await _prefs.getString(_key);
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) {
      await _prefs.remove(_key);
      return null;
    }
    return file;
  }

  /// Copies [source] into the app's own files, since the picker only returns
  /// a temporary file that Android may clean up.
  Future<File> save(File source) async {
    final folder = directory ?? await getApplicationDocumentsDirectory();
    final name = userId.isEmpty ? 'profile.jpg' : 'profile-$userId.jpg';
    final target = await source.copy(p.join(folder.path, name));
    await _prefs.setString(_key, target.path);
    return target;
  }

  Future<void> clear() async {
    final path = await _prefs.getString(_key);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    await _prefs.remove(_key);
  }
}

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => const GalleryPhotoPicker(),
);

final profilePhotoRepositoryProvider = Provider<ProfilePhotoRepository>(
  (ref) => ProfilePhotoRepository(
    ref.watch(sharedPreferencesProvider),
    userId: ref.watch(currentUserIdProvider),
  ),
);

/// The saved photo of the signed-in account, or null when there is none.
final profilePhotoProvider = FutureProvider<File?>(
  (ref) => ref.watch(profilePhotoRepositoryProvider).load(),
);
