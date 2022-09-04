import 'package:flutter/services.dart';

class TextureChannel {
  TextureChannel._();

  static final _instance = TextureChannel._();

  static TextureChannel get instance => _instance;

  final MethodChannel _methodChannel = const MethodChannel('texture_channel');

  Future<int?> registerTexture() async {
    final result = await _methodChannel.invokeMethod('registerTexture');
    return result['textureId'];
  }

  Future<void> renderTexture(
      String url, int textureId, int width, int height) async {
    final params = {};
    params["textureId"] = textureId;
    params["url"] = url;
    params["width"] = width;
    params["height"] = height;
    _methodChannel.invokeMethod('renderTexture', params);
  }

  Future<void> unregisterTexture(int textureId) async {
    print('destroyTextureId');
    final params = {};
    params["textureId"] = textureId;
    _methodChannel.invokeMethod('unregisterTexture', params);
  }
}
