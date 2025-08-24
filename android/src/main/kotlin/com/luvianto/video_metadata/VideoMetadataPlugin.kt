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
    when (call.method) {
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
        "title" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE).orEmpty(),
        "duration" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toInt() ?: 0,
        "width" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toInt() ?: 0,
        "height" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toInt() ?: 0,
        "bitrate" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)?.toInt() ?: 0,
        "rotation" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toInt() ?: 0,
        "frameRate" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE)?.toFloat() ?: 0f,

        "fileSize" to file.length(),
        "mimeType" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE).orEmpty(),

        "videoCodec" to mapCodec((0 until extractor.trackCount)
          .mapNotNull { extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME) }
          .firstOrNull { it.startsWith("video/") }),
          
        "audioCodec" to mapCodec((0 until extractor.trackCount)
          .mapNotNull { extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME) }
          .firstOrNull { it.startsWith("audio/") }),

        "author" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_AUTHOR).orEmpty(),
        "artist" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST).orEmpty(),
        "album" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM).orEmpty(),
        "genre" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_GENRE).orEmpty(),
        "comment" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_COMMENT).orEmpty(),
        "year" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_YEAR).orEmpty(),
        "date" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE).orEmpty(),
        "location" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_LOCATION).orEmpty()
      )
    } finally {
      extractor.release()
      retriever.release()
    }
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
