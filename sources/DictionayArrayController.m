//	DictionayArrayController.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "DictionaryBinderManager.h"
#import "DictionayArrayController.h"

NSString* const EBArrayControllerPboardType = @"EBArrayControllerPboardType";


@implementation DictionayArrayController




//-- tableView:writeRows:toPasteboard
// ドラッグの許可
- (BOOL)tableView:(NSTableView*)tableView 
writeRowsWithIndexes:(NSIndexSet*)rowIndexes 
	 toPasteboard:(NSPasteboard*)pboard
{
    [pboard declareTypes:[NSArray arrayWithObject:EBArrayControllerPboardType] owner:nil];
    
    NSArray* arrangedObjects = [self arrangedObjects];
    
    NSMutableArray* reps = [NSMutableArray array];
    NSUInteger index = [rowIndexes firstIndex];
    
	do {
		if (index >= [arrangedObjects count]) break;
        [reps addObject:[NSNumber numberWithUnsignedInteger:index]];
    } while ((index = [rowIndexes indexGreaterThanIndex:index]) != NSNotFound);
    
    if ([reps count] == 0) return NO;
    
	[pboard setPropertyList:reps forType:EBArrayControllerPboardType];
    
    return YES;
}



//-- tableView:validateDrop:proposedRow:proposedDropOperation:
//
-(NSDragOperation)  tableView:(NSTableView*) tv
				 validateDrop:(id <NSDraggingInfo>) info
				  proposedRow:(NSInteger) row
		proposedDropOperation:(NSTableViewDropOperation) operation
{
	NSPasteboard* pboard = [info draggingPasteboard];
    if (!pboard) return NSDragOperationNone;
    
    if (![[pboard types] containsObject:EBArrayControllerPboardType]) return NSDragOperationNone;
    
    if (operation == NSTableViewDropOn) return NSDragOperationNone;
	return NSDragOperationMove;
}


//-- tableView:acceptDrop:row:dropOperation:
// 
-(BOOL)	tableView : (NSTableView*) tv
	   acceptDrop : (id <NSDraggingInfo>) info
			  row : (NSInteger) row
	dropOperation : (NSTableViewDropOperation) op
{
	NSPasteboard* pboard;
	pboard = [info draggingPasteboard];
	if (!pboard) return NO;
	
	NSArray* droppingReps = [pboard propertyListForType:EBArrayControllerPboardType];
	if(!droppingReps || ![droppingReps isKindOfClass:[NSArray class]] || [droppingReps count] == 0){
		return NO;
	}
	
	NSMutableArray* arrangedObjects = [self arrangedObjects];
    
	NSMutableArray* droppingRows = [NSMutableArray array];
	NSUInteger insertIndex = row;
	NSMutableIndexSet* indexes = [[[NSMutableIndexSet alloc] init] autorelease];
	for(NSNumber* droppingIndex in droppingReps){
		NSUInteger index = [droppingIndex unsignedIntValue];
		
		id obj = [arrangedObjects objectAtIndex:index];
		if (!obj) continue;
		
		if (index < row) insertIndex--;
		[droppingRows addObject:obj];
		[indexes addIndex:index];
	}
	[self removeObjectsAtArrangedObjectIndexes:indexes];
	//[arrangedObjects removeObjectsInArray:droppingRows];
	if(insertIndex > [arrangedObjects count]){
		insertIndex =  [arrangedObjects count];
	}
	NSIndexSet* insertIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertIndex, [droppingRows count])];
	[self insertObjects:droppingRows atArrangedObjectIndexes:insertIndexes];
	[self rearrangeObjects];
	
	return YES;
}
@end



@implementation DictionaryArrayTable
-(void) awakeFromNib
{	
	[self registerForDraggedTypes:[NSArray arrayWithObject:EBArrayControllerPboardType]];
}

@end

