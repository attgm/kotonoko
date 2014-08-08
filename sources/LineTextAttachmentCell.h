//	LineTextAttachmentCell.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//



#import <Cocoa/Cocoa.h>


@interface LineTextAttachmentCell : NSObject <NSTextAttachmentCell> {
	NSTextAttachment* _attachment;
	CGFloat	_width;
}

@property (retain, nonatomic) NSTextAttachment* attachment;


@end
