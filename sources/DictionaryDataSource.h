//	DictionaryDataSource.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DictionaryDataSource : NSObject <NSTableViewDataSource>
{
    NSMutableArray*	mValue;
    int	mCount;
    
    IBOutlet id mTableView;
    NSArray* mDraggedNodes;
    
    NSString* mEditString;
}

//- (void) init;
- (void) awakeFromNib;
- (void) dealloc;

- (void) setValues : (NSMutableArray*) aVolue;
- (void) setValue : (NSString*) aName
	     path : (NSString*) aPath
	  subbook : (NSInteger) aSubbook;
- (void) removeSelectedvalue;
- (void) setAppendixToSelected : (NSString*) inPath;

/* TableView:dataSource (protocol:NSTableDataSource) */
	 
-(NSUInteger) numberOfRowsInTableView : (NSTableView*) aTableView;

-(id)				tableView : (NSTableView*) aTableView
    objectValueForTableColumn : (NSTableColumn*) aTableColumn
                          row : (NSInteger) rowIndex;

/* TableView delegate */
- (BOOL) tableView		: (NSTableView*)	aTableView
   shouldSelectRow		: (NSInteger)			rowIndex;

- (BOOL) tableView              : (NSTableView*)             tableView
         acceptDrop             : (id <NSDraggingInfo>)      info
         row                    : (NSInteger)                      row
         dropOperation          : (NSTableViewDropOperation) operation;

- (BOOL)    tableView : (NSTableView *)  tableView
			writeRows : (NSArray*)       rows
         toPasteboard : (NSPasteboard*)  pboard;

- (BOOL) selectionShouldChangeInTableView : (NSTableView *)aTableView;

- (BOOL)            tableView : (NSTableView *)aTableView
        shouldEditTableColumn : (NSTableColumn *)aTableColumn
                          row : (NSInteger)rowIndex;

- (NSDragOperation)tableView:(NSTableView*) tv
				validateDrop:(id <NSDraggingInfo>) info
				 proposedRow:(NSInteger) row
	   proposedDropOperation:(NSTableViewDropOperation) operation;
@end
