package com.luvianto.video_metadata

import java.io.File
import android.media.MediaFormat
import android.media.MediaExtractor
import android.media.MediaMetadataRetriever
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class VideoMetadataPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video_metadata")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    val path = call.argument<String>("path")
    if (path.isNullOrBlank()) {
        result.error("INVALID_ARGUMENT", "Video path is required", null)
        return
    }

    when (call.method) {
        "getVideoMetadata" -> {
            val retriever = MediaMetadataRetriever().apply { setDataSource(path) }
            val extractor = MediaExtractor().apply { setDataSource(path) }
            val file = File(path)

            runCatching {
                getVideoMetadata(retriever, extractor, file)
            }.onSuccess {
                result.success(it)
            }.onFailure {
                result.error("ERROR", it.message, null)
            }.also {
                extractor.release()
                retriever.release()
            }
        }

        "getOptionalMetadata" -> {
            val retriever = MediaMetadataRetriever().apply { setDataSource(path) }
            runCatching {
                getOptionalMetadata(retriever)
            }.onSuccess {
                result.success(it)
            }.onFailure {
                result.error("ERROR", it.message, null)
            }.also {
                retriever.release()
            }
        }

        else -> result.notImplemented()
    }
}


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getVideoMetadata(
    retriever: MediaMetadataRetriever,
    extractor: MediaExtractor,
    file: File
  ): Map<String, Any> {
    val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toIntOrNull() ?: 0
    val width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH).orEmpty()
    val height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT).orEmpty()
    val bitrate = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)?.toIntOrNull() ?: 0
    val rotation = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
    val frameRate = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE)?.toFloatOrNull() ?: 0f
    
    val videoMime = (0 until extractor.trackCount)
        .mapNotNull { extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME) }
        .firstOrNull { it.startsWith("video/") }

    val audioMime = (0 until extractor.trackCount)
        .mapNotNull { extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME) }
        .firstOrNull { it.startsWith("audio/") }

    return mapOf(
      "duration" to duration,
      "width" to width,
      "height" to height,
      "bitrate" to bitrate,
      "rotation" to rotation,
      "frameRate" to frameRate,
      "fileSize" to file.length(),
      "videoCodec" to mapCodec(videoMime).orEmpty(),
      "audioCodec" to mapCodec(audioMime).orEmpty(),
      "mimeType" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE).orEmpty()
    )
  }


  private fun getOptionalMetadata(retriever: MediaMetadataRetriever): Map<String, String> {
    return mapOf(
      "title" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE).orEmpty(),
      "author" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_AUTHOR).orEmpty(),
      "artist" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST).orEmpty(),
      "album" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM).orEmpty(),
      "genre" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_GENRE).orEmpty(),
      "year" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_YEAR).orEmpty(),
      "date" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE).orEmpty(),
      "location" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_LOCATION).orEmpty()
    )
  }

  private fun mapCodec(mime: String?): String? = when (mime) {
    "video/avc" -> "H.264 / AVC"
    "video/hevc" -> "H.265 / HEVC"
    "video/mp4v-es" -> "MPEG-4"
    "video/x-vnd.on2.vp8" -> "VP8"
    "video/x-vnd.on2.vp9" -> "VP9"
    "video/av01" -> "AV1"
    "audio/mp4a-latm" -> "AAC"
    "audio/mpeg" -> "MP3"
    "audio/opus" -> "Opus"
    "audio/vorbis" -> "Vorbis"
    else -> mime
  }
}
