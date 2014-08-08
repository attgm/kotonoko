//	KeyEquivalentToNumberTransformer.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "KeyEquivalentToNumberTransformer.h"


@implementation KeyEquivalentToNumberTransformer
//-- transformedValueClass
//
+ (Class) transformedValueClass
{
	return [NSNumber class];
}


//-- allowsReverseTransformation
//
+ (BOOL) allowsReverseTransformation
{
	return YES;
}


//-- transformedValue
// transfer KeyEquivalentToNumber to NSFont
- (id) transformedValue:(id)value
{
	return [NSNumber numberWithInt:
		((![value isKindOfClass:[NSString class]] || [value isEqualToString:@""]) ? -1 : [value intValue])];
}


//-- reverseTransformedValue
// reverse-transfer NSFont to font
- (id) reverseTransformedValue:(id) value
{
	if (value == nil && ![value isKindOfClass:[NSNumber class]]) return @"";
	
	if([value intValue] < 0 || 9 < [value intValue]){
		return @"";
	}
	return [value stringValue];
}

@end
