//	DictionaryBinder.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "ELDefines.h"

@class DictionaryListItem;
@class ACBindingItem;

enum {
	kFalseBinderId = 0,
	kFirstBinderId = 1000
};

@interface DictionaryBinder : NSObject {
	NSUInteger  _identifier;
	NSMutableDictionary* _bindingItems;
	
	NSString*	_tagName;
	NSString*	_title;
	BOOL		_quickTag;
	NSString*	_keyEquivalent;
	
	NSNumber*	_index;
	NSString*	_prefId;
}

@property (retain) NSNumber* index;
@property (retain) NSString* prefId;

-(id) init;
-(void) dealloc;

-(Class) valueClassForBinding:(NSString *)binding;
-(void) bind:(NSString *)binding toObject:(id)observableObject withKeyPath:(NSString *)keyPath options:(NSDictionary *) options;
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
-(NSDictionary*) infoForBinding:(NSString *) binding;
-(void) unbind:(NSString *) binding;
-(void) unbindAll;

-(NSUInteger) binderId;
-(void) setBinderId:(unsigned) identifier;
-(NSString*) title;
-(void) setTitle:(NSString*) tagName;
-(NSString*) tagName;
-(void) setTagName:(NSString*) tagName;
-(BOOL) quickTag;
-(void) setQuickTag:(BOOL) quick;
-(NSString*) keyEquivalent;
-(void) setKeyEquivalent:(NSString*) keyEquivalent;	

-(void) observeTagName:(ACBindingItem*) item;
-(void) observeTitle:(ACBindingItem*) item;
-(void) observeQuickTab:(ACBindingItem*) item;
-(void) observeKeyEquivalent:(ACBindingItem*) item;

-(NSArray*) search:(NSString*)word method:(ESearchMethod)method max:(NSInteger)maxHits paramator:(NSDictionary*)paramator;
-(NSArray*) searchMethods;

-(NSAttributedString*) copyrightWithParamator:(NSDictionary*) paramator;

@end

//---
@interface SingleBinder : DictionaryBinder {
	NSString* _ebook;
}

-(id) initWithDictionaryListItem:(DictionaryListItem*) item;
+(SingleBinder*) binderWithDictionaryListItem:(DictionaryListItem*) item;
-(NSArray*) search:(NSString*)word method:(ESearchMethod)method max:(NSInteger)maxHits paramator:(NSDictionary*)paramator;
-(NSArray*) multiSearch:(NSArray*)entries index:(NSInteger)index max:(NSInteger)maxHits paramator:(NSDictionary*)paramator;
-(NSArray*) searchMethods;

-(NSAttributedString*) copyrightWithParamator:(NSDictionary*)paramator;
-(NSAttributedString*) menuWithParamator:(NSDictionary*) paramator;

-(NSArray*) fontTable:(NSInteger)kind;
-(void) savePrefToFile:(NSString*)filename format:(NSInteger)format;
-(void) loadPrefFromFile:(NSString*)filename;
-(NSArray*) multiSearchEntries:(NSInteger)index;
-(NSArray*) multiSearchCandidates:(NSInteger)index entry:(NSInteger)entry;
@end


//-- 
@interface MultiBinder : DictionaryBinder {
	NSMutableArray*			_dictionaryList;
	NSMutableDictionary*	_paramators;
}

-(id) initWithParamators:(NSMutableDictionary*)paramators prefId:(NSString*)identify;
+(MultiBinder*) binderWithParamators:(NSMutableDictionary*)tag prefId:(NSString*)identify;
-(void) addDictionaryIdentify:(NSString*) identify;
-(void) observeDictionaryList:(ACBindingItem*) item;
-(NSArray*) search:(NSString*)word method:(ESearchMethod)method max:(NSInteger)maxHits paramator:(NSDictionary*)paramator;
-(NSArray*) searchMethods;

-(BOOL) hasSearchMethod:(ESearchMethod) method;
-(NSAttributedString*) copyrightWithParamator:(NSDictionary*) paramator;
@end
