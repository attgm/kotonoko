//	LineTextAttachmentCell.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import <Cocoa/Cocoa.h>


@interface LineTextAttachmentCell : NSObject <NSTextAttachmentCell> {
	NSTextAttachment* _attachment;
	float	_width;
}



@end
