//	SwipeView.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <AppKit/AppKit.h>

@protocol SwipeViewDelegate
-(void) refleshCurrentDisplayCache:(NSBitmapImageRep*) bitmap;
-(NSBitmapImageRep*) getHistoryDisplayCacheBy:(NSInteger) offset;
-(void) swipeBy:(NSInteger) offset;
-(void) switchDictionaryBy:(NSInteger) offset;
-(BOOL) canSwipeBy:(NSInteger)offset;
@end


@interface SwipeView : NSView {
    IBOutlet id<SwipeViewDelegate> _delegate;
    NSColor* _backgroundPattern;
    CIFilter* _transitionFilter;
    CGRect _imageRect;
    CGFloat* _animationPosition;
}


-(NSBitmapImageRep*) getBitmapImageRepForCachingDisplay;
-(void)swipeTo:(NSInteger) offset;

@end
