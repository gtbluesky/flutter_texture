package com.gtbluesky.flutter_texture

import android.graphics.Color
import android.view.Surface
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.TextureRegistry


/** FlutterTexturePlugin */
class FlutterTexturePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var textureRegistry: TextureRegistry
    private val surfaceTextureEntryMap = mutableMapOf<Long, TextureRegistry.SurfaceTextureEntry>()
    private val surfaceMap = mutableMapOf<Long, Surface>()

    companion object {
        private const val INVALID_TEXTURE_ID = -1L
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "texture_channel")
        channel.setMethodCallHandler(this)
        textureRegistry = flutterPluginBinding.textureRegistry
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "registerTexture" -> {
                val surfaceTextureEntry = textureRegistry.createSurfaceTexture()
                val textureId = surfaceTextureEntry?.id() ?: INVALID_TEXTURE_ID
                val reply = mutableMapOf<String, Long>()
                reply["textureId"] = textureId
                surfaceTextureEntryMap[textureId] = surfaceTextureEntry
                result.success(reply)
            }
            "renderTexture" -> {
                val textureId = call.argument<Int>("textureId")?.toLong() ?: INVALID_TEXTURE_ID
                val url: String = call.argument("url") ?: ""
                val width: Int = call.argument("width") ?: 0
                val height: Int = call.argument("height") ?: 0
                if (textureId >= 0 && url.isNotEmpty()) {
                    val surfaceTextureEntry = surfaceTextureEntryMap[textureId]
                    val surfaceTexture = surfaceTextureEntry?.surfaceTexture()
                    surfaceTexture?.setDefaultBufferSize(width, height)
                    val surface = surfaceMap[textureId] ?: Surface(surfaceTexture).also {
                        surfaceMap[textureId] = it
                    }
                    val canvas = surface.lockCanvas(null)
                    canvas.drawColor(Color.BLUE)
                    surface.unlockCanvasAndPost(canvas)
                    result.success(null)
                }
            }
            "unregisterTexture" -> {
                val textureId = call.argument<Int>("textureId")?.toLong() ?: INVALID_TEXTURE_ID
                if (textureId >= 0) {
                    surfaceTextureEntryMap.remove(textureId)?.release()
                    surfaceMap.remove(textureId)?.release()
                }
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
