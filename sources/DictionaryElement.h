//	DictionaryElement.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ELDefines.h"

@interface DictionaryElement : NSObject {
    NSAttributedString*	_heading;
    NSData*				_rawData;
	NSURL*				_url;
};

@property (readonly) NSAttributedString* attributedString;
@property (readonly) NSString* string;
@property (readonly) NSURL* anchor;
@property (readonly) NSString* URLString;

- (id) initWithHeading : (NSAttributedString*) inHeading
				anchor : (EBLocation) inLocation
				  data : (NSData*) inRawData;
- (id) initWithHeading : (NSAttributedString*) inHeading
				   url : (NSString*) url;

+ (id) elementWithHeading : (NSAttributedString*) inHeading
				   anchor : (EBLocation) inLocation;
 
+ (id) elementWithHeading : (NSAttributedString*) inHeading
				   anchor : (EBLocation) inLocation
					 data : (NSData*) inRawData;

+ (id) elementWithHeading : (NSAttributedString*) inHeading
					  url : (NSString*) url;

- (void) dealloc;

- (BOOL) canSelect;
- (NSData*) dataForEntry;

+(NSString*) locationToURLString:(EBLocation) location;

@end
