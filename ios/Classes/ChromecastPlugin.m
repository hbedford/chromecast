#import "ChromecastPlugin.h"
#if __has_include(<chromecast/chromecast-Swift.h>)
#import <chromecast/chromecast-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "chromecast-Swift.h"
#endif

@implementation ChromecastPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftChromecastPlugin registerWithRegistrar:registrar];
}
@end
