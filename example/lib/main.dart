import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_metadata/video_metadata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = "Waiting for codec test...";

  @override
  void initState() {
    super.initState();
    _runCodecTest();
  }

  Future<void> _runCodecTest() async {
    try {
      // Load the bundled asset
      final byteData = await rootBundle.load('assets/MP4_SAMPLE_480_1_5MG.mp4');

      // Write it into a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/MP4_SAMPLE_480_1_5MG.mp4');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Get metadata using the plugin
      final result = await VideoMetadata.getMetadata(file.path);

      setState(() {
        _result = formatMetadata(result ?? {});
      });
    } catch (e) {
      setState(() {
        _result = "Error: $e";
      });
    }
  }

  String formatMetadata(Map<String, dynamic> data) {
    final durationMs = data['duration'] ?? 0;
    final durationSec = (durationMs / 1000).toStringAsFixed(2);

    final width = data['width'] ?? 0;
    final height = data['height'] ?? 0;

    final bitrateBps = data['bitrate'] ?? 0;
    final bitrateMbps = (bitrateBps / 1000000).toStringAsFixed(2);

    final videoCodec = data['videoCodec'] ?? 'Unknown';
    final audioCodec = data['audioCodec'] ?? 'Unknown';
    final mimeType = data['mimeType'] ?? 'Unknown';

    final fileSizeBytes = data['fileSize'] ?? 0;
    final fileSizeMB = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);

    return '''
Duration       : $durationSec s
Resolution     : $width x $height
Bitrate        : $bitrateMbps Mbps
Video Codec    : $videoCodec
Audio Codec    : $audioCodec
MIME Type      : $mimeType
File Size      : $fileSizeMB MB
''';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('MediaCodec Test Harness')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              _result,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
