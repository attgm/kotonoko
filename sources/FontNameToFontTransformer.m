//	FontNameToFontTransformer.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "FontNameToFontTransformer.h"
#import "PreferenceUtilities.h"

@implementation FontNameToFontTransformer


//-- transformedValueClass
//
+ (Class) transformedValueClass
{
	return [NSFont class];
}


//-- allowsReverseTransformation
//
+ (BOOL) allowsReverseTransformation
{
	return YES;
}


//-- transformedValue
// transfer fontname to NSFont
- (id) transformedValue:(id)value
{
	if([value isKindOfClass:[NSString class]]){
		return [PreferenceUtilities transforFontNameToFont:value];
	}else{
		return [NSFont userFontOfSize:0.0];
	}
}


//-- reverseTransformedValue
// reverse-transfer NSFont to font
- (id) reverseTransformedValue:(id) value
{
	if (value == nil) return nil;
	return [NSString stringWithFormat:@"%@ %.0f", [value fontName], [value pointSize]];
}

@end
