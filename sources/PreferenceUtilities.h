//	PreferenceUtilities.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferenceUtilities : NSObject {
}

+(NSColor*) transforColorNameToColor:(NSString*) value;
+(NSFont*) transforFontNameToFont:(NSString*) value;
+(NSString*) transforColorToWebColor:(NSColor*) color;

@end
