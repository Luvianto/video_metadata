import 'package:flutter_test/flutter_test.dart';
import 'package:video_metadata/video_metadata_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock implementation of [VideoMetadataPlatform] for testing.
/// Returns fake metadata including a `title` field and null-safe defaults.
class MockVideoMetadataPlatform
    with MockPlatformInterfaceMixin
    implements VideoMetadataPlatform {
  @override
  Future<Map<String, dynamic>> getMetadata(String path) async {
    return {
      "title": "Sample Video",
      "duration": 30528,
      "width": 480,
      "height": 270,
      "bitrate": 411431,
      "rotation": 0,
      "frameRate": 29.97,
      "fileSize": 1570024,
      "mimeType": "video/mp4",
      "videoCodec": "H.264 / AVC",
      "audioCodec": "AAC",
      "author": "John Doe",
      "artist": "John Doe",
      "album": "Sample Album",
      "genre": "Education",
      "comment": "Test comment",
      "year": "2025",
      "date": "2025-08-24",
      "location": "Unknown",
    };
  }
}

void main() {
  test('getMetadata returns fake metadata including all fields', () async {
    final mockPlatform = MockVideoMetadataPlatform();
    VideoMetadataPlatform.instance = mockPlatform;

    final metadata = await VideoMetadataPlatform.instance.getMetadata(
      'fake_path.mp4',
    );

    expect(metadata['title'], 'Sample Video');
    expect(metadata['duration'], 30528);
    expect(metadata['width'], 480);
    expect(metadata['height'], 270);
    expect(metadata['bitrate'], 411431);
    expect(metadata['rotation'], 0);
    expect(metadata['frameRate'], 29.97);
    expect(metadata['fileSize'], 1570024);
    expect(metadata['mimeType'], 'video/mp4');
    expect(metadata['videoCodec'], 'H.264 / AVC');
    expect(metadata['audioCodec'], 'AAC');
    expect(metadata['author'], 'John Doe');
    expect(metadata['artist'], 'John Doe');
    expect(metadata['album'], 'Sample Album');
    expect(metadata['genre'], 'Education');
    expect(metadata['comment'], 'Test comment');
    expect(metadata['year'], '2025');
    expect(metadata['date'], '2025-08-24');
    expect(metadata['location'], 'Unknown');
  });
}
