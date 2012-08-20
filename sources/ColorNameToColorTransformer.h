//	ColorNameToColorTransformer.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ColorNameToColorTransformer : NSValueTransformer {

}

+ (Class) transformedValueClass;
+ (BOOL) allowsReverseTransformation;
- (id) transformedValue:(id)value;
- (id) reverseTransformedValue:(id) value;


@end
