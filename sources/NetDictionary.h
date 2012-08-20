//	NetDictionary.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "DictionaryManager.h"


@interface NetDictionary : NSObject <DictionaryProtocol> {
	NSMutableDictionary* _paramators;
}

-(id) initWithData:(NSData*) data;
+(NetDictionary*) netDictionaryWithData:(NSData*) data;

-(BOOL) parseData:(NSData*) data;

-(void) setValue:(id) value forKey:(NSString*) key;
-(id) valueForKey:(NSString*) key;
-(NSString*) tagName;
-(void) setTagName : (NSString*) value;
-(void) setId:(NSString*) identify;
-(BOOL) selected;
-(void) setSelected:(BOOL) selection;

-(NSArray*) search:(NSString*)word method:(ESearchMethod)method max:(int)maxHits paramator:(NSDictionary*)paramator;
-(BOOL)		hasSearchMethod:(ESearchMethod) method;
-(NSArray*) searchMethods;

-(BOOL)	isDictionaryHost:(NSString*) serverName;
@end
