import 'package:flutter/services.dart';

class VideoMetadata {
  static const MethodChannel _channel = MethodChannel('video_metadata');

  static Future<Map<String, dynamic>?> getVideoMetadata(String path) async {
    final result = await _channel.invokeMethod('getVideoMetadata', {
      'path': path,
    });
    return (result as Map?)?.cast<String, dynamic>();
  }

  static Future<Map<String, String?>?> getOptionalMetadata(String path) async {
    final result = await _channel.invokeMethod('getOptionalMetadata', {
      'path': path,
    });
    return (result as Map?)?.cast<String, String>();
  }
}
