//	DictionaryBinderManager.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "PreferenceModal.h"
#import "DictionaryManager.h"
#import "DictionaryBinder.h"
#import "DictionaryBinderManager.h"

#import "ACBindingItem.h"

const NSString* kSingleDictionariesBindingIdentifier = @"single";
const NSString* kMultipleDictionariesBindingIdentifier = @"multiple";
const NSString* kQuickTabBindingIdentifier = @"quicktag";

DictionaryBinderManager* sSharedDictionaryBinderManager = NULL;


@implementation DictionaryBinderManager

#pragma mark Shared Instance
//-- sharedDictionaryBinderManager
// return shared preference 
+(DictionaryBinderManager*) sharedDictionaryBinderManager
{
	if(!sSharedDictionaryBinderManager){
		sSharedDictionaryBinderManager = [[DictionaryBinderManager alloc] init];
	}
	return sSharedDictionaryBinderManager;
}


//-- findDictionaryBinderForId
// binder idで binderを検索し, 返す 
+(DictionaryBinder*) findDictionaryBinderForId:(NSUInteger) identify
{
	return [[DictionaryBinderManager sharedDictionaryBinderManager] binderForId:identify];
}


#pragma mark Initialize
//-- init
// 初期化
-(id) init
{
	self = [super init];
	if(sSharedDictionaryBinderManager){
		[self release];
		return sSharedDictionaryBinderManager;
	}
    if(self){
        sSharedDictionaryBinderManager = self;
        [self initialize];
    }
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[self unbindAll];
	[_binders release];
	[_bindingItems release];
	if(sSharedDictionaryBinderManager == self){
		sSharedDictionaryBinderManager = nil;
	}
	[_quickTagFilterPredicate release];
	[super dealloc];
}


//-- initialize
// 初期化
-(void) initialize
{
	_quickTagFilterPredicate = [[NSPredicate predicateWithFormat:@"SELF.quickTag == YES"] retain];
		
	[self		bind:@"single" 
			toObject:[DictionaryManager sharedDictionaryManager]
		 withKeyPath:@"dictionaries"
			 options:nil];
	[self		bind:@"multiple"
			toObject:[PreferenceModal sharedPreference]
		 withKeyPath:@"ebookSet"
			 options:nil];
}


#pragma mark Interface
//-- binderForId
// binder id でbinderを検索する
-(DictionaryBinder*) binderForId:(NSUInteger) binderId
{
	NSEnumerator* e = [_binders objectEnumerator];
	DictionaryBinder* it;
	while(it = [e nextObject]){
		if([it binderId] == binderId){
			return it;
		}
	}
	return nil;
}


//-- binderForTitle
// title でbinderを検索する
-(DictionaryBinder*) binderForTitle:(NSString*) title
{
	NSEnumerator* e = [_binders objectEnumerator];
	DictionaryBinder* it;
	while(it = [e nextObject]){
		if([title isEqualToString:[it title]]){
			return it;
		}
	}
	return nil;
}


//-- nextBinder
// 次のbinderを検索する
-(DictionaryBinder*) nextBinder:(DictionaryBinder*) binder
{
	NSUInteger currentIndex = [_binders indexOfObject:binder];
	if (currentIndex == NSNotFound) return nil;
	
	NSUInteger nextIndex = ((currentIndex + 1) < [_binders count]) ? currentIndex + 1 : 0;
	return (nextIndex < [_binders count]) ? [_binders objectAtIndex:nextIndex] : nil;
}



//-- privBinder
// 前のbinderを検索する
-(DictionaryBinder*) privBinder:(DictionaryBinder*) binder
{
	NSUInteger currentIndex = [_binders indexOfObject:binder];
	if (currentIndex == NSNotFound) return nil;
	
	NSUInteger nextIndex = (currentIndex > 0) ? currentIndex-1 : [_binders count] - 1;
	return (nextIndex < [_binders count]) ? [_binders objectAtIndex:nextIndex] : nil;
}


//-- firstBinder
//  先頭のbinderを返す
-(DictionaryBinder*) firstBinder
{
	return [_binders count] > 0 ? [_binders objectAtIndex:0] : nil;
}


//-- scanSingleDictionaries
// 単体辞書を走査する
-(void) scanSingleDictionaries:(NSArray*) array
{
	NSEnumerator* e = [array objectEnumerator];
	_numOfSingleDictionaties = 0;
	id it;
	while(it = [e nextObject]){
		DictionaryBinder* binder = [SingleBinder binderWithDictionaryListItem:it];
		[binder addObserver:self forKeyPath:@"quickTag" options:NSKeyValueObservingOptionNew context:(id)kQuickTabBindingIdentifier];
		[_binders addObject:binder];
		_numOfSingleDictionaties++;
	}
}


//-- scanMultiDictionaries
// 辞書セットを走査する
-(void) scanMultiDictionaries:(NSArray*) array
{
	NSUInteger idx = 1;
	NSEnumerator* e = [array objectEnumerator];
	NSMutableDictionary* it;
	while(it = [e nextObject]){
		MultiBinder* binder = [MultiBinder binderWithParamators:it
                                                         prefId:[NSString stringWithFormat:@"binder:%lu", (unsigned long)(idx++)]];
		[binder addObserver:self forKeyPath:@"quickTag" options:NSKeyValueObservingOptionNew context:(id)kQuickTabBindingIdentifier];
		[_binders addObject:binder];
	}	
}


#pragma mark Binding
//-- bindingItems
// bindingItemを返す
-(NSDictionary*) bindingItems
{
	if(!_bindingItems){
		_bindingItems = [[NSDictionary alloc] initWithObjectsAndKeys:
			[ACBindingItem bindingItemFromSelector:@selector(observeSingleDictionaries:)
										valueClass:[NSArray class]
										identifier:kSingleDictionariesBindingIdentifier]
			, kSingleDictionariesBindingIdentifier,
			[ACBindingItem bindingItemFromSelector:@selector(observeMultipleDictionaries:)
										valueClass:[NSArray class]
										identifier:kMultipleDictionariesBindingIdentifier]
			, kMultipleDictionariesBindingIdentifier,
			nil];
	}
	
	return _bindingItems;
}



//-- valueClassForBinding:
//
-(Class) valueClassForBinding:(NSString *)binding {
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		return [item valueClass];
	}else{
		return [super valueClassForBinding:binding];
	}
}



//-- bind:toObject:withKeyPath:options:
//
- (void)		bind : (NSString *) binding
			toObject : (id) observableObject
		 withKeyPath : (NSString *) keyPath
			 options : (NSDictionary *) options
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		[item setObservedController:observableObject];
		[item setObservedKeyPath:keyPath];
		[item setTransformerName:[options objectForKey:@"NSValueTransformerName"]];
		[observableObject addObserver:self
						   forKeyPath:keyPath
							  options:0
							  context:[item identifier]];
		[self performSelector:[item selector] withObject:item];
	}else{
		[super bind:binding toObject:observableObject withKeyPath:keyPath options:options];
	}
}    



//-- observeValueForKeyPath:ofObject:change:context:
//
- (void) observeValueForKeyPath : (NSString *) keyPath
					   ofObject : (id) object
						 change : (NSDictionary *) change
						context : (void *) context
{
	ACBindingItem* item = [[self bindingItems] objectForKey:context];
	if(item){
		[self performSelector:[item selector] withObject:item];
	}else if(context == kQuickTabBindingIdentifier){
		[self observeQuickTab];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}    


//-- infoForBinding
//
- (NSDictionary*) infoForBinding : (NSString *) binding
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		return [item infoForBinding];
	}else{
		return [super infoForBinding:binding];
	}
}


//-- unbind
// 
- (void) unbind : (NSString *) binding
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		[[item observedController] removeObserver:self forKeyPath:[item observedKeyPath]];
		[item unbind];
	}else{
		[super unbind:binding];
	}
}


//-- unbindAll
// 全てのobserverからselfを除く
-(void) unbindAll
{
	NSEnumerator* e = [[self bindingItems] objectEnumerator];
	ACBindingItem* item;
	while(item = [e nextObject]){
		[[item observedController] removeObserver:self forKeyPath:[item observedKeyPath]];
		[item unbind];
	}
}


#pragma mark Observer

//-- observeSingleDictionaries
// 単体辞書をbinder形式にする
-(void) observeSingleDictionaries:(ACBindingItem*) item
{
	[self willChangeValueForKey:@"binders"];
	[self recalcBinderIndex];
	if(_binders){
		NSEnumerator* e = [_binders objectEnumerator];
		id it;
		while(it = [e nextObject]){
			[it removeObserver:self forKeyPath:@"quickTag"];
		}
		[_binders release];
	}
	_binders = [[NSMutableArray alloc] init];
	
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		[self scanSingleDictionaries:value];
	}
	ACBindingItem* mitem = [[self bindingItems] objectForKey:@"multiple"];
	if(mitem && [mitem observedController]){
		id mvalue = [[mitem observedController] valueForKeyPath:[mitem observedKeyPath]];
		if(mvalue && [mvalue isKindOfClass:[mitem valueClass]]){
			[self scanMultiDictionaries:mvalue];
		}
	}
	[self sortBinderByIndex];
	[self didChangeValueForKey:@"binders"];
}


//-- observeMultipleDictionaries
// 辞書セットをbinder形式にする
-(void) observeMultipleDictionaries:(ACBindingItem*) item
{
	[self willChangeValueForKey:@"binders"];
	[self recalcBinderIndex];
	if([_binders count] > _numOfSingleDictionaties){
		int i;
		for(i = _numOfSingleDictionaties; i < [_binders count]; i++){
			[[_binders objectAtIndex:i] removeObserver:self forKeyPath:@"quickTag"];
		}
		[_binders removeObjectsInRange:
			NSMakeRange(_numOfSingleDictionaties, [_binders count] - _numOfSingleDictionaties)];
	}
	
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		[self scanMultiDictionaries:value];
	}
	[self sortBinderByIndex];
	[self didChangeValueForKey:@"binders"];
}



//-- observeQuickTab
// quick tagに含まれるエントリが変更された時に呼び出される
-(void) observeQuickTab
{
	[self willChangeValueForKey:@"quickTagFilterPredicate"];
	[_quickTagFilterPredicate release];
	_quickTagFilterPredicate = nil;
	[self didChangeValueForKey:@"quickTagFilterPredicate"];	
	[self willChangeValueForKey:@"quickTagFilterPredicate"];
	_quickTagFilterPredicate = [[NSPredicate predicateWithFormat:@"SELF.quickTag == YES"] retain];
	[self didChangeValueForKey:@"quickTagFilterPredicate"];	
	
}

#pragma mark Index
//-- recalcBinderIndex
// binderのindexを再計算する
-(void) recalcBinderIndex
{
	NSInteger index = 0;
	for(DictionaryBinder* binder in _binders){
		NSString* prefId = [binder prefId];
		if(prefId){
			id pref = [PreferenceModal dictioanryPreferenceForId:prefId];
			[pref setValue:[NSNumber numberWithUnsignedInteger:index++] forKey:@"index"];
		}
	}
}


//-- sortBinderByIndex
// index順にbinderをsortする
-(void) sortBinderByIndex
{
	[self willChangeValueForKey:@"binders"];
	NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	[_binders sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	[descriptor release];
	[self didChangeValueForKey:@"binders"];
}



@end
