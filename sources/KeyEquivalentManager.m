//	KeyEquivalentManager.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "KeyEquivalentManager.h"

static KeyEquivalentManager* sKeyEquivalentManager = nil;

@implementation KeyEquivalentManager
//-- sharedKeyEquivalentManager
//
+(KeyEquivalentManager*) sharedKeyEquivalentManager
{
	if(!sKeyEquivalentManager){
		sKeyEquivalentManager = [[KeyEquivalentManager alloc] init];
	}
	return sKeyEquivalentManager;
}


//-- init
// 初期化
-(id) init
{
	self = [super init];
    if(self){
        _keyEquivalent = [[NSMutableDictionary alloc] init];
    }
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[_keyEquivalent release];
	[super dealloc];
}


//-- setKeyEquivalent
// key equivalent の設定
-(void) setKeyEquivalent:(NSString*)keyEquivalent
				toObject:(id)object
{
	if([keyEquivalent length] > 0){
		id oldObject = [_keyEquivalent objectForKey:keyEquivalent];
		if(oldObject){
			[oldObject setKeyEquivalent:@""];
		}
		[_keyEquivalent setObject:object forKey:keyEquivalent];
	}
}


//-- unsetKeyEquivalent
// key equivalentを設定
-(void) unsetKeyEquivalent:(NSString*)keyEquivalent
				  toObject:(id)object
{
	if([keyEquivalent length] > 0){
		id oldObject = [_keyEquivalent objectForKey:keyEquivalent];
		if(oldObject == object){
			[_keyEquivalent removeObjectForKey:keyEquivalent];
		}
	}
}


@end
