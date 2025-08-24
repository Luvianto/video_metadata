import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_metadata/video_metadata_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelVideoMetadata platform = MethodChannelVideoMetadata();
  const MethodChannel channel = MethodChannel('video_metadata');

  final Map<String, dynamic> mockMetadata = {
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

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getMetadata') {
            return mockMetadata;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getMetadata returns all expected fields', () async {
    final Map<String, dynamic> result = await platform.getMetadata(
      '/fake/path/sample.mp4',
    );

    expect(result, isNotNull);
    expect(result, containsPair('title', 'Sample Video'));
    expect(result, containsPair('duration', 30528));
    expect(result, containsPair('width', 480));
    expect(result, containsPair('height', 270));
    expect(result, containsPair('bitrate', 411431));
    expect(result, containsPair('rotation', 0));
    expect(result, containsPair('frameRate', 29.97));
    expect(result, containsPair('fileSize', 1570024));
    expect(result, containsPair('mimeType', 'video/mp4'));
    expect(result, containsPair('videoCodec', 'H.264 / AVC'));
    expect(result, containsPair('audioCodec', 'AAC'));
    expect(result, containsPair('author', 'John Doe'));
    expect(result, containsPair('artist', 'John Doe'));
    expect(result, containsPair('album', 'Sample Album'));
    expect(result, containsPair('genre', 'Education'));
    expect(result, containsPair('comment', 'Test comment'));
    expect(result, containsPair('year', '2025'));
    expect(result, containsPair('date', '2025-08-24'));
    expect(result, containsPair('location', 'Unknown'));
  });

  test('getMetadata returns empty map if platform returns null', () async {
    // Override to return null
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (MethodCall methodCall) async => null,
        );

    final Map<String, dynamic> result = await platform.getMetadata(
      '/fake/path/sample.mp4',
    );
    expect(result, isEmpty);
  });

  test('getMetadata throws PlatformException if unknown method', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Unknown method');
        });
    try {
      await platform.getMetadata('/fake/path/sample.mp4');
      fail('Should have thrown a PlatformException');
    } on PlatformException catch (e) {
      expect(e.code, 'ERROR');
      expect(e.message, 'Unknown method');
    }
  });
}
