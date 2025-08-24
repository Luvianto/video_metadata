import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'video_metadata_method_channel.dart';

abstract class VideoMetadataPlatform extends PlatformInterface {
  VideoMetadataPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoMetadataPlatform _instance = MethodChannelVideoMetadata();
  static VideoMetadataPlatform get instance => _instance;

  static set instance(VideoMetadataPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>> getMetadata(String path) {
    throw UnimplementedError('getMetadata() has not been implemented.');
  }
}
