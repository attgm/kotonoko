//	DictionaryDataSource.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "DictionaryDataSource.h"


#define DictuinaryPboardType @"KotonokoDicType"

@implementation DictionaryDataSource

//-- awakeFromNib
//
- (void) awakeFromNib
{
    [mTableView registerForDraggedTypes:[NSArray arrayWithObjects:DictuinaryPboardType, nil]];
}


//-- dealloc
//
- (void) dealloc
{
    [mValue release];
	[super dealloc];
}


//--- setValues
// value�̒ǉ�
- (void) setValues : (NSMutableArray*) inValues;
{
    [mValue release];
    mValue = inValues;
    [mValue retain];
    
    [mTableView deselectAll:self];
    [mTableView reloadData];
}


//-- setValue:path:subbook
//
- (void) setValue : (NSString*) aName
			 path : (NSString*) aPath
		  subbook : (int) aSubbook
{
    [mValue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:aName, @"name", aPath, @"path", nil]];
    [mTableView reloadData];
}


//-- removeSelectedvalue
//
- (void) removeSelectedvalue
{
    int index = [mTableView selectedRow];
    if(index > -1){
		[mValue removeObjectAtIndex:index];
		[mTableView deselectAll:self];
		[mTableView reloadData];
	}
}


//--- setAppendixToSelected
// �I�����Ă��鎫���ɕt�^��ݒ肷��.
- (void) setAppendixToSelected : (NSString*) inPath
{
    int index = [mTableView selectedRow];
    if(index > -1){
		[[mValue objectAtIndex:index] setObject:inPath forKey:@"appendix"];
    }
}


//-- numberOfRowsInTableView:
//
-(int) numberOfRowsInTableView : (NSTableView*) aTableView
{
    return [mValue count];
}


//-- tableView:objectValueForTableColumn:row
//
-(id)				tableView : (NSTableView*) aTableView
    objectValueForTableColumn : (NSTableColumn*) aTableColumn
						  row : (int) rowIndex
{
    id identifier;
    
   //identity NSNumber* nCol = [ NSNumber numberWithInt:rowIndex ];
    identifier = [aTableColumn identifier];
    if([identifier isEqualToString:@"path"]){
		if(floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_2){
            return [[[NSFileManager defaultManager]
                componentsToDisplayForPath : [[mValue objectAtIndex:rowIndex] objectForKey:identifier] ]
                    componentsJoinedByString : @":"];            
        }else{
			return [[mValue objectAtIndex:rowIndex] objectForKey:identifier];
		}
	}else if([identifier isEqualToString:@"appendix"]) {
		return [[[mValue objectAtIndex:rowIndex] objectForKey:identifier] lastPathComponent];
    }else if([identifier isEqualToString:@"string"]) {
		return [[mValue objectAtIndex:rowIndex] objectForKey:identifier];
    }else if([identifier isEqualToString:@"icon"]) {
		return [[[mValue objectAtIndex:rowIndex] objectForKey:@"name"] isEqualToString:@"folder"] ?
				[NSImage imageNamed:@"icon_folder"] : [NSImage imageNamed:@"icon_book"];
	}	
    
    return @"";
}


//-- tableView:shouldSelectRow
//
- (BOOL) tableView		: (NSTableView*)	aTableView
    shouldSelectRow		: (int)			rowIndex
{
    if(rowIndex >=0 && rowIndex < [mValue count]){
		//[mDeletePathButton setEnabled:YES];
		//[mAddAppendixButton setEnabled:YES];
		return YES;
    }
    return NO;
}


//-- tableView:acceptDrop:row:dropOperation
//
- (BOOL) tableView              : (NSTableView*)             tableView
	 acceptDrop             : (id <NSDraggingInfo>)      info
	 row                    : (int)                      row
	 dropOperation          : (NSTableViewDropOperation) operation
{
	NSPasteboard* pboard = [info draggingPasteboard];
    
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:DictuinaryPboardType]]){
		unsigned int count = [mDraggedNodes count];
		NSEnumerator *draggedNodesEnum = [mDraggedNodes objectEnumerator];
		NSMutableArray* draggedItems = [NSMutableArray arrayWithCapacity:count];
		unsigned int insertIndex = row;
		id obj;

		// �ꉞ�����I���\�ɂ���悤�ɂ���΂��Ă݂�
		while ((obj = [draggedNodesEnum nextObject])) {
			unsigned int index = [obj intValue];
			[draggedItems addObject:[mValue objectAtIndex:index]];
			[mValue removeObjectAtIndex:index];
			if (index < insertIndex) insertIndex--;
		}

		draggedNodesEnum = [draggedItems objectEnumerator];
		while ((obj = [draggedNodesEnum nextObject])) {
			[mValue insertObject:obj atIndex:insertIndex++];
		}
		[mTableView reloadData];
		// �����I���\�ɂ���Ȃ炱�����Ȃ�Ƃ����Ȃ��Ƃ�
		[mTableView selectRow:(insertIndex-1) byExtendingSelection:NO];
    }
    return TRUE;
}


//-- tableView:writeRows:toPasteboard
//
- (BOOL)    tableView : (NSTableView *)  tableView
			writeRows : (NSArray*)       rows
         toPasteboard : (NSPasteboard*)  pboard
{
    [pboard declareTypes:[NSArray arrayWithObjects:DictuinaryPboardType, nil] owner:nil];
    [pboard setData:[NSData data] forType:DictuinaryPboardType];

    mDraggedNodes = rows;
    return YES;
}


//-- selectionShouldChangeInTableView:
//
- (BOOL) selectionShouldChangeInTableView : (NSTableView *)aTableView
{
    //[mDeletePathButton setEnabled:NO];
    //[mAddAppendixButton setEnabled:NO];
    return YES;
}


//-- tableView:validateDrop:proposedRow:proposedDropOperation:
//
- (NSDragOperation)tableView:(NSTableView*) tv
				validateDrop:(id <NSDraggingInfo>) info
				 proposedRow:(int) row
	   proposedDropOperation:(NSTableViewDropOperation) operation
{
    return (operation == NSTableViewDropAbove) ?
			NSDragOperationMove : NSDragOperationNone;
}


//-- tableView:shouldEditTableColumn:row:
//
- (BOOL)            tableView : (NSTableView *)aTableView
        shouldEditTableColumn : (NSTableColumn *)aTableColumn
                          row : (int)rowIndex
{
    return NO;
}

@end

