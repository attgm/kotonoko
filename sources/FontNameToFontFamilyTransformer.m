//	FontNameToFontFamilyTransformer.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "FontNameToFontFamilyTransformer.h"


@implementation FontNameToFontFamilyTransformer


//-- transformedValueClass
//
+ (Class) transformedValueClass
{
	return [NSString class];
}


//-- allowsReverseTransformation
//
+ (BOOL) allowsReverseTransformation
{
	return NO;
}


//-- transformedValue
// transfer fontname to NSFont
- (id) transformedValue:(id)value
{
	if (value == nil || [value isKindOfClass:[NSNull class]]) return nil;
	NSArray* fontTable = [value componentsSeparatedByString:@" "];
	if([fontTable count] == 2){
		return [fontTable objectAtIndex:0];
	}
	return nil;
}

@end
