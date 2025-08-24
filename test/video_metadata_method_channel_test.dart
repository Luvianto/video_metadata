import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_metadata/video_metadata_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelVideoMetadata platform = MethodChannelVideoMetadata();
  const MethodChannel channel = MethodChannel('video_metadata');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getMetadata') {
            return {
              'duration': 30528,
              'width': 480,
              'height': 270,
              'bitrate': 411431,
              'mimeType': 'video/mp4',
              'videoCodec': 'H.264 / AVC',
              'audioCodec': 'AAC',
              'fileSize': 1570024,
            };
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getMetadata returns expected map', () async {
    final result = await platform.getMetadata('/fake/path/sample.mp4');

    expect(result['duration'], 30528);
    expect(result['width'], 480);
    expect(result['height'], 270);
    expect(result['bitrate'], 411431);
    expect(result['videoCodec'], 'H.264 / AVC');
    expect(result['audioCodec'], 'AAC');
    expect(result['fileSize'], 1570024);
  });
}
