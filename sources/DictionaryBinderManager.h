//	DictionaryBinderManager.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class ACBindingItem;
@class DictionaryBinder;

@interface DictionaryBinderManager : NSObject {
	NSMutableArray* _binders;
	unsigned int	_numOfSingleDictionaties;
	
	NSPredicate*	_quickTagFilterPredicate;
	NSDictionary*	_bindingItems;
}

+(DictionaryBinderManager*) sharedDictionaryBinderManager;
+(DictionaryBinder*) findDictionaryBinderForId:(NSUInteger)identify;
-(id) init;
-(void) dealloc;
-(void) initialize;

-(Class) valueClassForBinding:(NSString *)binding;
-(void) bind:(NSString *)binding toObject:(id)observableObject withKeyPath:(NSString *)keyPath options:(NSDictionary *) options;
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
-(NSDictionary*) infoForBinding:(NSString *) binding;
-(void) unbind:(NSString *) binding;
-(void) unbindAll;

-(void) observeSingleDictionaries:(ACBindingItem*) item;
-(void) observeMultipleDictionaries:(ACBindingItem*) item;
-(void) observeQuickTab;

-(void) scanSingleDictionaries:(NSArray*) array;
-(void) scanMultiDictionaries:(NSArray*) array;


-(DictionaryBinder*) nextBinder:(DictionaryBinder*) binder;
-(DictionaryBinder*) privBinder:(DictionaryBinder*) binder;
-(DictionaryBinder*) binderForId:(unsigned int) binderId;
-(DictionaryBinder*) binderForTitle:(NSString*) title;
-(DictionaryBinder*) firstBinder;

-(void) recalcBinderIndex;
-(void) sortBinderByIndex;
@end
