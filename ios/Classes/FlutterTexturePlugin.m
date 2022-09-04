#import "FlutterTexturePlugin.h"
#if __has_include(<flutter_texture/flutter_texture-Swift.h>)
#import <flutter_texture/flutter_texture-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_texture-Swift.h"
#endif

@implementation FlutterTexturePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterTexturePlugin registerWithRegistrar:registrar];
}
@end
