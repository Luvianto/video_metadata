import 'package:flutter/services.dart';

class VideoMetadata {
  static const MethodChannel _channel = MethodChannel('video_metadata');

  static Future<Map<String, dynamic>?> getMetadata(String path) async {
    final result = await _channel.invokeMethod<Map<String, dynamic>>(
      'getMetadata',
      {'path': path},
    );
    return result?.map((key, value) => MapEntry(key.toString(), value));
  }
}
