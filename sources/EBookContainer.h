//	EBookContainer.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class EBook;

@interface EBookContainer : NSObject {
	EBook*			_ebook;
	NSDictionary*	_paramator;
	
	NSMutableAttributedString* _string;
	NSMutableDictionary* _attribute;

	NSUInteger		_referenceStack;
	NSString*		_referenceURL;
}


-(id)initWithEBook:(EBook*)inBook;
-(void)dealloc;

-(EBook*) ebook;
-(int) ebookNumber;

-(void) setParamator:(NSDictionary*) paramator;
-(id) paramatorForkey:(NSString*) key;
-(BOOL) hasParamator;

-(void) appendString:(NSString*)inString;
-(void) appendAttributedString:(NSAttributedString*) string;
-(void) insertString:(NSString*)inString atIndex:(unsigned) inIndex;
-(NSString*) string;

-(NSUInteger) referenceMaker;
-(void) stackReference;
-(void) setReferenceURL:(NSString*)string;
-(void) insertReference;
-(void) insertReferenceWithURL:(NSString*)string range:(NSRange)referenceRange;

-(NSAttributedString*) attributedString;
-(void) setAttribute:(NSDictionary*) attribute;
-(void) addAttribute:(NSDictionary*) attribute;
-(void) removeAttribute:(NSString*) key;
-(void) setCenterTextAlignment:(BOOL) center;
-(NSColor*) currentTextColor;

-(void) appendImage:(NSImage*) string;

@end;

