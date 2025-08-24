import 'package:flutter_test/flutter_test.dart';
import 'package:video_metadata/video_metadata_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVideoMetadataPlatform
    with MockPlatformInterfaceMixin
    implements VideoMetadataPlatform {
  @override
  Future<Map<String, dynamic>> getMetadata(String path) async {
    return {
      "duration": 30528,
      "width": 480,
      "height": 270,
      "bitrate": 411431,
      "mimeType": "video/mp4",
      "videoCodec": "H.264 / AVC",
      "audioCodec": "AAC",
      "fileSize": 1570024,
    };
  }
}

void main() {
  test('getMetadata returns fake metadata', () async {
    final mockPlatform = MockVideoMetadataPlatform();
    VideoMetadataPlatform.instance = mockPlatform;

    final metadata =
        await (VideoMetadataPlatform.instance as MockVideoMetadataPlatform)
            .getMetadata('fake_path.mp4');
    expect(metadata['width'], 480);
    expect(metadata['height'], 270);
    expect(metadata['videoCodec'], 'H.264 / AVC');
    expect(metadata['audioCodec'], 'AAC');
    expect(metadata['fileSize'], 1570024);
  });
}
