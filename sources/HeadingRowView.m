//	HeadingController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
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


//-- background
/*-(NSColor*) backgroundColor
{
    if(self.isGroupRowStyle){
        return [NSColor colorWithCalibratedWhite:0.95f alpha:.5f];
    }else{
        return [super backgroundColor];
    }
}*/




//-- drawRect
//
/*- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    if(self.isGroupRowStyle == YES){
        NSRect bounds = self.bounds;
        NSColor* color = [NSColor colorWithCalibratedWhite:0.95f alpha:.5f];
        [color set];
        NSRectFill(bounds);
 
        NSRect bounds = self.bounds;
        
        // NSColor* color = [PreferenceModal colorForKey:kDictionaryBackgroundColor];
        //NSColor *beginColor = [NSColor colorWithDeviceRed:0.41f green:0.45f blue:0.53f alpha:1.0f];
        //NSColor *endColor = [NSColor colorWithDeviceRed:0.27f green:0.31f blue:0.39f alpha:1.0f];
        NSColor *beginColor = [NSColor colorWithDeviceRed:0.57f green:0.62f blue:0.72f alpha:1.0f];
        NSColor *endColor = [NSColor colorWithDeviceRed:0.47f green:0.52f blue:0.62f alpha:1.0f];
        //NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.64 green:0.68 blue:0.75 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:0.45 green:0.50 blue:0.60 alpha:1.0]];
        NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:beginColor endingColor:endColor];
        [gradient drawInRect:bounds angle:90.0];
        [gradient release];
        
        [[NSColor grayColor] set];
        
        [NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x, bounds.origin.y + bounds.size.height)
                                  toPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
    }else{
        [super drawBackgroundInRect:dirtyRect];
    }
}*/


@end

