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
  String _result = "Waiting for Video Metadata...";

  @override
  void initState() {
    super.initState();
    _runMetadataTest();
  }

  Future<void> _runMetadataTest() async {
    try {
      // Load the bundled asset
      final byteData = await rootBundle.load('assets/MP4_SAMPLE_480_1_5MG.mp4');

      // Write it into a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/MP4_SAMPLE_480_1_5MG.mp4');
      if (!file.existsSync()) {
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      // Get Video Metadata using the plugin
      final videoMetadata = await VideoMetadata.getVideoMetadata(file.path);
      print(videoMetadata.toString());
      final optionalMetadata = await VideoMetadata.getOptionalMetadata(
        file.path,
      );
      print(optionalMetadata.toString());

      setState(() {
        _result =
            formatVideoMetadata(videoMetadata ?? {}) +
            formatOptionalMetadata(optionalMetadata ?? {});
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _result = "Error: $e";
      });
    }
  }

  String formatDuration(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String formatVideoMetadata(Map<String, dynamic> data) {
    final durationMs = data['duration'];
    final width = data['width'];
    final height = data['height'];
    final bitrateBps = data['bitrate'];
    final fileSizeBytes = data['fileSize'];

    return '''
Duration       : ${formatDuration(durationMs)}
Resolution     : $width x $height
Bitrate        : ${(bitrateBps / 1000000).toStringAsFixed(2)} Mbps
Frame Rate     : ${data['frameRate']} fps
Rotation       : ${data['rotation']}°
Video Codec    : ${data['videoCodec']}
Audio Codec    : ${data['audioCodec']}
MIME Type      : ${data['mimeType']}
File Size      : ${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB
''';
  }

  String formatOptionalMetadata(Map<String, dynamic> data) {
    return '''
Title          : ${data['title']}
Author         : ${data['author']}
Artist         : ${data['artist']}
Album          : ${data['album']}
Genre          : ${data['genre']}
Year           : ${data['year']}
Date           : ${data['date']}
Location       : ${data['location']}
''';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Video Metadata Inspector')),
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
