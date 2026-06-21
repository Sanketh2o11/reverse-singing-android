import 'dart:io';
import 'dart:math';

class FileUtils {
  static String generateUuid() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  static Future<bool> fileExists(String path) => File(path).exists();

  static Future<int> fileSizeBytes(String path) async {
    final f = File(path);
    return await f.exists() ? await f.length() : 0;
  }

  static Future<void> deleteIfExists(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }
}
