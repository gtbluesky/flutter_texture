import 'package:flutter/material.dart';
import 'package:flutter_texture/src/channel/texture_channel.dart';

class TextureDemo extends StatefulWidget {
  const TextureDemo({Key? key}) : super(key: key);

  @override
  State<TextureDemo> createState() => _TextureDemoState();
}

const _kInvalidTextureId = -1;

class _TextureDemoState extends State<TextureDemo> {
  int _textureId = _kInvalidTextureId;

  @override
  void initState() {
    super.initState();
    TextureChannel.instance.registerTexture().then((value) {
      _textureId = value ?? _kInvalidTextureId;
      if (mounted) {
        setState(() {});
      }
      //5s后开始渲染
      Future.delayed(const Duration(seconds: 5), () {
        TextureChannel.instance
            .renderTexture('http://www.bilibili.com', _textureId, 100, 100);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _textureId == _kInvalidTextureId
        ? Container(
            color: Colors.white,
          )
        : Texture(textureId: _textureId);
  }

  @override
  void dispose() {
    super.dispose();
    if (_textureId != _kInvalidTextureId) {
      TextureChannel.instance.unregisterTexture(_textureId);
    }
  }
}
