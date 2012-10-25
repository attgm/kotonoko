//	HeadingController.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>



@interface HeadingController : NSArrayController {
}



- (BOOL)	tableView : (NSTableView*)tableView
	  shouldSelectRow : (int)rowIndex;

-(void)         tableView:(NSTableView *)tableView
          willDisplayCell:(id)cell
           forTableColumn:(NSTableColumn *)tableColumn
                      row:(int)row;
@end
