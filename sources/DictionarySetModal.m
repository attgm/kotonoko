//	DictionarySetModal.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "PreferenceModal.h"
#import "DictionaryManager.h"
#import "DictionarySetModal.h"

static void* kSelectionBindingIdentifier = (void*) @"ebookSet";
static void* kDictionariesBindingIdentifier = (void*) @"dictionaries";


@implementation DictionarySetModal

//-- init
// 初期化
-(id) init
{
	self = [super init];
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[_dictionarySetController removeObserver:self forKeyPath:@"selection"];
	[[DictionaryManager sharedDictionaryManager] removeObserver:self forKeyPath:@"dictionaries"];
	[super dealloc];
}


//-- finalize
// 後片付け
-(void) finalize
{
	[_dictionarySetController removeObserver:self forKeyPath:@"selection"];
	[[DictionaryManager sharedDictionaryManager] removeObserver:self forKeyPath:@"dictionaries"];
	[super finalize];
}


//-- awakeFromNib
// 
-(void) awakeFromNib
{
	[self initialize];
}


//-- initize
//
-(void) initialize
{
	if(_dictionarySetController){
		[_dictionarySetController addObserver:self
								   forKeyPath:@"selection"
									  options:0
									  context:kSelectionBindingIdentifier];
	}
	[[DictionaryManager sharedDictionaryManager] addObserver:self
												  forKeyPath:@"dictionaries"
													 options:0
													 context:kDictionariesBindingIdentifier];
	[self setSelectedDictionarySet];
	[self updateDictionaries];
	
}


#pragma mark Dictionary

//-- hasDictionary
//
-(BOOL) hasDictionary:(NSString*) identifier
{
	NSArray* array = [_selectedDictionary valueForKey:kEBookSetList];
	if(!array || ![array isKindOfClass:[NSArray class]]){ return NO; };
	NSEnumerator* e = [array objectEnumerator];
	id obj;
	while(obj = [e nextObject]){
		if([obj isEqualToString:identifier]){
			return YES;
		}
	}
	return NO;
}


//-- addDictionary
//
-(void) addDictionary:(NSString*) identifier
{
	[_selectedDictionary willChangeValueForKey:kEBookSetList];
	NSMutableArray* array = [_selectedDictionary valueForKey:kEBookSetList];
	if(array){
		[array addObject:identifier];
	}else{
		array = [NSMutableArray arrayWithObject:identifier];
		[_selectedDictionary setValue:array forKey:kEBookSetList];
	}
	[_selectedDictionary didChangeValueForKey:kEBookSetList];
}



//-- removeDictionary
//
-(void) removeDictionary:(NSString*) identifier
{
	[_selectedDictionary willChangeValueForKey:kEBookSetList];
	NSMutableArray* array = [_selectedDictionary valueForKey:kEBookSetList];
	if(!array || ![array isKindOfClass:[NSArray class]]){ return; };
	NSEnumerator* e = [array objectEnumerator];
	id obj;
	while(obj = [e nextObject]){
		if([obj isEqualToString:identifier]){
			[array removeObject:obj];
		}
	}
	[_selectedDictionary didChangeValueForKey:kEBookSetList];
}


#pragma mark Observer
//-- observeValueForKeyPath:ofObject:change:context:
//
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{	
	if (context == kSelectionBindingIdentifier) {
		[self setSelectedDictionarySet];
	}else if(context == kDictionariesBindingIdentifier){
		[self updateDictionaries];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


//-- setSelectedDictionarySet
// 選択されている辞書セットを設定する
-(void) setSelectedDictionarySet
{
	_selectedDictionary = [[_dictionarySetController selectedObjects] lastObject];
	if([_selectedDictionary valueForKey:@"title"] == NSNoSelectionMarker){
		_selectedDictionary = NULL;
	}
	[_tableView reloadData];
}


//-- updateDictionaries
// 辞書一覧の更新
-(void) updateDictionaries
{
	_dictionarySet = [[DictionaryManager sharedDictionaryManager] valueForKey:@"dictionaries"];
	[_tableView reloadData];
}


#pragma mark protocol:NSTableDataSource

//-- numberOfRowsInTableView
// 辞書の数を返す
-(NSInteger) numberOfRowsInTableView : (NSTableView*) aTableView
{
    return [_dictionarySet count];
}


//-- tableView:objectValueForTableColumn:row
// オブジェクトを返す
-(id)				tableView : (NSTableView*) aTableView
    objectValueForTableColumn : (NSTableColumn*) aTableColumn
						  row : (NSInteger) rowIndex
{
	static NSNumber *yes, *no;
	if(!yes){
		yes = [[NSNumber alloc] initWithBool:YES];
		no = [[NSNumber alloc] initWithBool:NO];
	}
	
	if(rowIndex >= 0 && rowIndex < [_dictionarySet count]){
		NSString* identifier = [aTableColumn identifier];
		if([identifier isEqualToString:@"title"]) {
			return [[_dictionarySet objectAtIndex:rowIndex] valueForKey:@"title"];
		}else if([identifier isEqualToString:@"selected"]) {
			return [self hasDictionary:[[_dictionarySet objectAtIndex:rowIndex] valueForKey:@"id"]] ? yes : no;
		}	
	}
	return @"";
}


//-- tableView:setObjectValue:forTableColumn:row
// データの変更
- (void) tableView : (NSTableView*)	aTableView
	setObjectValue : (id) anObject
	forTableColumn : (NSTableColumn *)	aTableColumn
			   row : (NSInteger) rowIndex
{
	id identifier = [aTableColumn identifier];
    
	if([identifier isEqualToString:@"selected"]) {
		if([anObject boolValue] == YES){
			[self addDictionary:[[_dictionarySet objectAtIndex:rowIndex] valueForKey:@"id"]];
		}else{
			[self removeDictionary:[[_dictionarySet objectAtIndex:rowIndex] valueForKey:@"id"]];
		}	
    }
}


//-- tableView:willDisplayCell:forTableColumn:row
// table viewが選択された時の処理
-(void) tableView : (NSTableView*) tableView
  willDisplayCell : (id) cell 
   forTableColumn : (NSTableColumn *) tableColumn
			  row : (NSInteger) rowIndex
{
	[cell setEnabled:(_selectedDictionary != NULL)]; 
}


@end
