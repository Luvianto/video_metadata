import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'video_metadata_platform_interface.dart';

class MethodChannelVideoMetadata extends VideoMetadataPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('video_metadata');

  @override
  Future<Map<String, dynamic>> getMetadata(String path) async {
    final result = await methodChannel.invokeMethod<Map>('getMetadata', {
      'path': path,
    });
    if (result == null) return {};
    return Map<String, dynamic>.from(result);
  }
}
