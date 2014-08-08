//	PreferenceUtilities.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "PreferenceUtilities.h"


@implementation PreferenceUtilities

//-- transforColorNameToColor
// 色名をNSColorに変換する
+(NSColor*) transforColorNameToColor:(NSString*) value
{
	if (value == nil || [value isKindOfClass:[NSNull class]]) return nil;
	
	NSArray* colorTable = [value componentsSeparatedByString:@" "];
    if([colorTable count] > 2){
		return	[NSColor colorWithCalibratedRed:[[colorTable objectAtIndex:0] floatValue]
										  green:[[colorTable objectAtIndex:1] floatValue]
										   blue:[[colorTable objectAtIndex:2] floatValue]
										  alpha:1.0];
    }
	return nil;
}


//-- transforFontNameToFont
// フォント名をNSFontに変換する
+(NSFont*) transforFontNameToFont:(NSString*) value
{
	if (value == nil || [value isKindOfClass:[NSNull class]]) return nil;
	NSArray* fontTable = [value componentsSeparatedByString:@" "];
	if([fontTable count] == 2){
		return [NSFont fontWithName:[fontTable objectAtIndex:0]
							   size:[[fontTable objectAtIndex:1] floatValue]];
	}
	return nil;
}


//-- transforColorToWebColor
// NSColorをWebカラー表記に変換する
+(NSString*) transforColorToWebColor:(NSColor*) color
{
	if (color == nil || [color isKindOfClass:[NSNull class]]) return nil;
	if ([color isKindOfClass:[NSColor class]]){
		return [NSString stringWithFormat:@"#%02x%02X%02x", (int)([color redComponent] * 0xFF)
				, (int)([color greenComponent] * 0xFF), (int)([color blueComponent] * 0xFF)];
	}
	return nil;
}


@end
