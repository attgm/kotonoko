//	KeyEquivalentManager.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@interface KeyEquivalentManager : NSObject {
	NSMutableDictionary* _keyEquivalent;
}

+(KeyEquivalentManager*) sharedKeyEquivalentManager;

-(id) init;
-(void) dealloc;

-(void) setKeyEquivalent:(NSString*)keyEquivalent toObject:(id)object;
-(void) unsetKeyEquivalent:(NSString*)keyEquivalent toObject:(id)object;

@end
