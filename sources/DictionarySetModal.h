//	DictionarySetModal.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DictionarySetModal : NSObject {
	IBOutlet NSArrayController* _dictionarySetController;
	IBOutlet NSTableView*	_tableView;
	
	NSMutableDictionary* _selectedDictionary;
	NSMutableArray* _dictionarySet;
}


-(void) initialize;

-(void) setSelectedDictionarySet;
-(void) updateDictionaries;

@end
