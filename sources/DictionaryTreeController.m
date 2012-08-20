//	DictionaryTreeController.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "DictionaryTreeController.h"


@implementation DictionaryTreeController

//-- canRemove
// 削除可能かどうかの判断
-(BOOL) canRemove
{
	return ([[self selectionIndexPath] length] == 1) ? YES : NO;
}


@end
