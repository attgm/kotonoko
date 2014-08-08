//	ColorNameToColorTransformer.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "ColorNameToColorTransformer.h"
#import "PreferenceUtilities.h"

@implementation ColorNameToColorTransformer

//-- transformedValueClass
//
+(Class) transformedValueClass
{
	return [NSColor class];
}


//-- allowsReverseTransformation
//
+(BOOL) allowsReverseTransformation
{
	return YES;
}


//-- transformedValue
// transfer fontname to NSColor
-(id) transformedValue:(id)value
{
	return [PreferenceUtilities transforColorNameToColor:value];
}



//-- reverseTransformedValue
// reverse-transfer NSColor to font
-(id) reverseTransformedValue:(id) value
{
	if (value == nil || ![value isKindOfClass:[NSColor class]]) return nil;
	
	CGFloat red, green, blue, alpha;
	[value getRed:&red green:&green blue:&blue alpha:&alpha];
    
	return [NSString stringWithFormat:@"%f %f %f 1.0", red, green, blue];
}

@end
