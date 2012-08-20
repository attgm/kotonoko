//	FontTableElement.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FontTableElement : NSObject {
	NSString*	_alternative;
	NSString*	_url;
	int			_identify;
	BOOL		_useAlternative;
};


-(id) initWithURL:(NSString*)url alternative:(NSString*)string use:(BOOL)use identify:(int)identify;
+(id) elementWithURL:(NSString*)url alternative:(NSString*)string use:(BOOL)use identify:(int)identify;

-(void) dealloc;

-(NSString*) alternativeString;
-(void) setAlternativeString:(NSString*) string;

-(BOOL) useAlternativeString;
-(void) setUseAlternativeString:(BOOL) useAlternative;

-(int) identify;
-(NSImage*) largeImageRepresentation;

-(NSImage*) imageRepresentation;

@end
