//	DictionaryManager.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "ELDefines.h"
#define kDidInitializeDictionaryManager @"DidInitializeDictionaryManager"
#define kAllDictionariesIsLoaded @"AllLoaded"

@class DictionaryListItem;
@class EBook;

@protocol DictionaryProtocol 
-(NSArray*) search:(NSString*)word method:(ESearchMethod)method max:(NSInteger)maxHits paramator:(NSDictionary*)paramator;
-(BOOL)		hasSearchMethod:(ESearchMethod) method;
-(NSArray*) searchMethods;
@end

@interface DictionaryManager : NSObject {
	NSMutableArray* _root;
	NSMutableArray* _dictionaries;
	NSMutableArray* _netDictionaries;
	
	NSTimer* _progressTimer;
    BOOL    _readableAll;
}

@property BOOL readableAll;

+(DictionaryManager*) sharedDictionaryManager;
-(id) init;
-(void) dealloc;
-(void) initialize;

-(void) createDictionaryArray;
-(void) scanDictionary:(NSTimer*) timer;
-(void) expandDirectory : (DictionaryListItem*) parent
			  recursion : (BOOL) recursion
               bookmark : (NSURL*) bookmark;
-(void) appendDirectory :(NSString*) path;

-(id <DictionaryProtocol>) dictionaryForIdentity:(NSString*) identity;
-(EBook*) ebookForEBookNumber:(NSUInteger) number;

-(void) addDictionary : (id <DictionaryProtocol>) item;
-(void) deleteDictionary:(id <DictionaryProtocol>) item;
-(void) deleteDictionaryAtIndex:(NSIndexSet*) indices;

-(NSUInteger) removeDirectory:(DictionaryListItem*) item;
-(void) removeDictionaryListItem:(DictionaryListItem*) item;


-(NSString*) uniqueDictionaryIdFromPath:(NSString*) path
							  directory:(NSString*) directoryName;

-(void) createNetDictionaryArray;
@end
