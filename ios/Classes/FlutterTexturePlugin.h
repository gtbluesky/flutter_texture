#if TARGET_OS_IOS
#import <Flutter/Flutter.h>
#else
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@interface FlutterTexturePlugin : NSObject<FlutterPlugin>
@end
