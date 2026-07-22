import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_data_safety.dart';
import '../../rescue/data/reasons_to_stop_repository.dart';
import '../domain/my_reasons_state.dart';
import '../domain/reason_media_item.dart';

class MyReasonsRepository {
  static const String _storageKey = 'my_reasons_state_v1';

  Future<MyReasonsState> getState() async {
    final prefs = await SharedPreferences.getInstance();
    final decoded = LocalDataSafety.decodeMap(prefs.getString(_storageKey));
    if (decoded.isNotEmpty) return MyReasonsState.fromMap(decoded);
    final legacy = await ReasonsToStopRepository().getReasons();
    final migrated = legacy
        .where((item) => item != ReasonsToStopRepository.otherReason)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return MyReasonsState(
      reasons: migrated.isEmpty ? <String>[] : <String>[migrated.first],
      media: const <ReasonMediaItem>[],
    );
  }

  Future<void> saveState(MyReasonsState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(state.copyWith(updatedAt: DateTime.now().toUtc()).toMap()),
    );
  }

  Future<ReasonMediaItem> importPhoto(XFile picked) {
    return _importFile(picked, ReasonMediaType.photo, '.jpg');
  }

  Future<ReasonMediaItem> importVideo(XFile picked) {
    return _importFile(picked, ReasonMediaType.video, '.mp4');
  }

  Future<ReasonMediaItem> _importFile(
    XFile picked,
    ReasonMediaType type,
    String fallback,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDirectory = Directory('${directory.path}/breakout_reasons');
    await mediaDirectory.create(recursive: true);
    final extension = _safeExtension(picked.path, fallback: fallback);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final destination = File(
      '${mediaDirectory.path}/reason_${type.name}_$id$extension',
    );
    await File(picked.path).copy(destination.path);
    return ReasonMediaItem(id: id, path: destination.path, type: type);
  }

  Future<void> deleteMedia(ReasonMediaItem item) async {
    final file = File(item.path);
    if (await file.exists()) await file.delete();
  }

  String _safeExtension(String path, {required String fallback}) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return fallback;
    final extension = name.substring(dot).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,6}$').hasMatch(extension)
        ? extension
        : fallback;
  }
}
