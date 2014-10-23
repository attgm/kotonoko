//	DictionaryListItem.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "ELDefines.h"
#import "DictionaryManager.h"

@class EBook;

@interface DictionaryListItem : NSObject {
	NSMutableDictionary* _paramators;
	NSMutableArray*		_children;
}

-(id) initWithPath:(NSString*) path;
+(DictionaryListItem*) dictionaryListItemWithPath:(NSString*) path ;


-(void) addChild:(DictionaryListItem*) item;
-(NSArray*) children;

-(void) setValue:(id) value forKey:(NSString*) key;
-(id) valueForKey:(NSString*) key;
-(NSString*) tagName;
-(void) setTagName:(NSString*) value;
-(void) setAppendix : (NSString*) path;

@end


@interface EBDictionary : DictionaryListItem <DictionaryProtocol> {
	
}

-(id) initWithEBook:(EBook*)book path:(NSString*) path  identify:(NSString*) dictionaryId;
+(EBDictionary*) dictionaryListItemWithEBook:(EBook*) book path:(NSString*) path  identify:(NSString*) dictionaryId;


-(NSArray*) search:(NSString*)word method:(ESearchMethod)method max:(NSInteger)maxHits paramator:(NSDictionary*)paramator;
-(BOOL) hasSearchMethod:(ESearchMethod) method;
-(NSArray*) multiSearchTitles;

@end;