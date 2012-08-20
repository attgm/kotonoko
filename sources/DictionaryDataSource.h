//	DictionaryDataSource.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DictionaryDataSource : NSObject
{
    NSMutableArray*	mValue;
    int	mCount;
    
    IBOutlet id mTableView;
    //IBOutlet id mDeletePathButton;
    //IBOutlet id mAddAppendixButton;
    NSArray* mDraggedNodes;
    
    NSString* mEditString;
}

//- (void) init;
- (void) awakeFromNib;
- (void) dealloc;

- (void) setValues : (NSMutableArray*) aVolue;
- (void) setValue : (NSString*) aName
	     path : (NSString*) aPath
	  subbook : (int) aSubbook;
- (void) removeSelectedvalue;
- (void) setAppendixToSelected : (NSString*) inPath;

/* TableView:dataSource (protocol:NSTableDataSource) */
- (void) tableView 		: (NSTableView   *)	aTableView
	 setObjectValue		: (id)			anObject
	 forTableColumn 	: (NSTableColumn *)	aTableColumn
	 row			: (int)			rowIndex;
	 
-(int) numberOfRowsInTableView : (NSTableView*) aTableView;

-(id) tableView			: (NSTableView*)	aTableView
    objectValueForTableColumn	: (NSTableColumn*)	aTableColumn
    row				: (int)			rowIndex;

/* TableView delegate */
- (BOOL) tableView		: (NSTableView*)	aTableView
    shouldSelectRow		: (int)			rowIndex;

- (BOOL) tableView              : (NSTableView*)             tableView
	 acceptDrop             : (id <NSDraggingInfo>)      info
	 row                    : (int)                      row
	 dropOperation          : (NSTableViewDropOperation) operation;

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
@end
