import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum PhotoSource { camera, gallery }

/// Takes or picks photos and stores them in the app's documents folder.
/// Images are resized/compressed by the picker (~1600 px JPEG, WORKER_APP_SPEC).
abstract interface class PhotoCaptureService {
  /// Returns local file paths (empty when the worker cancels).
  Future<List<String>> pick(PhotoSource source, {required String fileStem});
}

class ImagePickerPhotoCaptureService implements PhotoCaptureService {
  ImagePickerPhotoCaptureService([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _maxSide = 1600.0;
  static const _quality = 80;

  @override
  Future<List<String>> pick(
    PhotoSource source, {
    required String fileStem,
  }) async {
    final List<XFile> files;
    if (source == PhotoSource.camera) {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
      files = [?file];
    } else {
      files = await _picker.pickMultiImage(
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
    }
    if (files.isEmpty) return const [];

    final dir = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'photos'),
    );
    await dir.create(recursive: true);
    final paths = <String>[];
    for (var i = 0; i < files.length; i++) {
      final target = p.join(dir.path, '${fileStem}_$i.jpg');
      await File(files[i].path).copy(target);
      paths.add(target);
    }
    return paths;
  }
}
