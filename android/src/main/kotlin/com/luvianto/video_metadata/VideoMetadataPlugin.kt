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

  override fun onMethodCall(call: MethodCall, result: Result) {when (call.method) {
    "getMetadata" -> {
      val path = call.argument<String>("path")
      if (path.isNullOrBlank()) {
        result.error("INVALID_ARGUMENT", "Video path is required", null)
      } else {
        runCatching { getVideoMetadata(path) }
          .onSuccess(result::success)
          .onFailure { result.error("ERROR", it.message, null) }
      }
    }
    else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getVideoMetadata(path: String): Map<String, Any?> {
    val retriever = MediaMetadataRetriever().apply { setDataSource(path) }
    val extractor = MediaExtractor().apply { setDataSource(path) }
    val file = File(path)

    return try {
      mapOf(
        "title" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE),
        "duration" to retriever.getLong(MediaMetadataRetriever.METADATA_KEY_DURATION),
        "width" to retriever.getInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH),
        "height" to retriever.getInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT),
        "bitrate" to retriever.getInt(MediaMetadataRetriever.METADATA_KEY_BITRATE),
        "mimeType" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE),
        "videoCodec" to mapCodec(findCodec(extractor, "video/")),
        "audioCodec" to mapCodec(findCodec(extractor, "audio/")),
        "fileSize" to file.length()
      )
    } finally {
      extractor.release()
      retriever.release()
    }
  }

  private fun findCodec(extractor: MediaExtractor, prefix: String): String? =
    (0 until extractor.trackCount)
      .mapNotNull { extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME) }
      .firstOrNull { it.startsWith(prefix) }

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

  private fun MediaMetadataRetriever.getInt(key: Int): Int? =
    extractMetadata(key)?.toIntOrNull()

  private fun MediaMetadataRetriever.getLong(key: Int): Long? =
    extractMetadata(key)?.toLongOrNull()
}
