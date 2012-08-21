//	HeadingController.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "HeadingRowView.h"
#import "PreferenceModal.h"

@implementation HeadingRowView

//-- initWithFrame
//
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}


//-- drawRect
//
- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    if(self.isGroupRowStyle == YES){
        NSRect bounds = self.bounds;
        
       // NSColor* color = [PreferenceModal colorForKey:kDictionaryBackgroundColor];
        NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.45 green:0.50 blue:0.60 alpha:1.0]
                                                    endingColor:[NSColor colorWithCalibratedRed:0.45 green:0.50 blue:0.60 alpha:0.7]];
        [gradient drawInRect:bounds angle:90.0];
        
        [[NSColor grayColor] set];
        
        [NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x, bounds.origin.y + bounds.size.height)
                                  toPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];

    }else{
        [super drawBackgroundInRect:dirtyRect];
    }
}


@end

