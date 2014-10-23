//	SwipeView.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "PreferenceModal.h"
#import "SwipeView.h"

const static CGFloat PAGE_CURL_ANGLE = M_PI - M_PI / 12;
@implementation SwipeView

//-- awakeFromNib
//
- (void) awakeFromNib
{
    _animationPosition = nil;
}


#pragma mark draw
//-- drawRect
//
- (void)drawRect:(NSRect) rect
{
    if(_animationPosition != nil){
        CGFloat position = *_animationPosition;
        
        CIContext* context = [[NSGraphicsContext currentContext] CIContext];
        //CGRect imageRect = [_currentImage extent];
        NSRect bounds = [self bounds];
        CGRect destRect = *(CGRect*)&bounds;
        //destRect.origin.x = position * bounds.size.width; /**/
        //[context drawImage:_currentImage inRect:destRect fromRect:imageRect];
        
        //NSRect bounds = [self bounds];
        //NSPoint origin = NSMakePoint(bounds.origin.x + position * bounds.size.width, bounds.origin.y);
        
        
        //[NSGraphicsContext saveGraphicsState];
        
        /*NSShadow  *shadow  = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowOffset: NSMakeSize(0, 0)];
        [shadow setShadowBlurRadius: 4];
        [shadow setShadowColor: [NSColor blackColor]];

        [shadow set];*/
        [_transitionFilter setValue:[NSNumber numberWithFloat:position] forKey:@"inputTime"];

        [context drawImage:[_transitionFilter valueForKey:@"outputImage"] inRect:destRect fromRect:_imageRect];
        //[_currentImage compositeToPoint:origin operation:NSCompositeSourceOver];
        //[NSGraphicsContext restoreGraphicsState];
    }
}


#pragma mark Swipe
//-- wantsScrollEventsForSwipeTrackingOnAxis
// 
- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(NSEventGestureAxis)axis {
    return (axis == NSEventGestureAxisHorizontal) ? YES : NO;
}


//-- scrollWheel
// 
- (void)scrollWheel:(NSEvent *)event
{
    if ([event phase] == NSEventPhaseNone) return;
    if (fabsf([event scrollingDeltaX]) <= fabsf([event scrollingDeltaY])) return;
    if (![NSEvent isSwipeTrackingFromScrollEventsEnabled]) return;
    
    if (_animationPosition != nil) return;
    
    CGFloat numPagesToLeft = -1.0;
    CGFloat numPagesToRight = 1.0;
    Boolean isBackword = [event scrollingDeltaX] > 0.0f ? YES : NO;
    if (![_delegate canSwipeBy:(isBackword ? -1 : 1)]) return;
    
    
    NSBitmapImageRep* image = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:image];
    
    CIImage* currentImage = [[CIImage alloc] initWithBitmapImageRep:image];
    [_delegate refleshCurrentDisplayCache:image];
    
    NSBitmapImageRep* nextImage = [_delegate getHistoryDisplayCacheBy:(isBackword ? -1 : 1)];
    CIImage* targetImage = (nextImage != nil) ? [[CIImage alloc] initWithBitmapImageRep:nextImage] : currentImage;
    _imageRect = [currentImage extent];
    [self setSubviews:[NSArray array]];
    
    NSRect rect = [self bounds];
    _transitionFilter = [CIFilter filterWithName:@"CIPageCurlWithShadowTransition"];
    
    [_transitionFilter setDefaults];
    [_transitionFilter setValue:[NSNumber numberWithFloat:PAGE_CURL_ANGLE] forKey:@"inputAngle"];
    [_transitionFilter setValue:[CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height] forKey:@"inputExtent"];
    [_transitionFilter setValue:(isBackword ? targetImage : currentImage) forKey:@"inputImage"];
    [_transitionFilter setValue:(isBackword ? currentImage : targetImage) forKey:@"inputTargetImage"];
    
    

    __block CGFloat animationFloat = 0.0f;
    [event trackSwipeEventWithOptions:NSEventSwipeTrackingClampGestureAmount 
             dampenAmountThresholdMin:numPagesToLeft
                                  max:numPagesToRight
                         usingHandler:^(CGFloat gestureAmount, NSEventPhase phase, BOOL isComplete, BOOL *stop){
        if (phase == NSEventPhaseBegan) {
            
        }
        
        if(isBackword && gestureAmount > 0.0f){
            animationFloat = 1.0f - gestureAmount;
        }else if(!isBackword && gestureAmount < 0.0f){
            animationFloat = -gestureAmount;
        }else{
            animationFloat = 0.0f;
        }
        [self setNeedsDisplay:YES];
         
        if (phase == NSEventPhaseEnded) {
        } else if (phase == NSEventPhaseCancelled) {
        }
         
        if (isComplete) {
            if(isBackword && gestureAmount == 1.0f){
                [self swipeTo:-1];
            }else if(!isBackword && gestureAmount == -1.0f){
                [self swipeTo:1];
            }else{
                [self swipeTo:0];
            }
        }
    }];
    
    _animationPosition = &animationFloat;
}

//-- swipeTo:
// swipe to backword/forward contents
-(void) swipeTo:(NSInteger) offset
{
    _transitionFilter = nil;
    _animationPosition = nil;
    [_delegate swipeBy:offset];
}

//-- swipeWithEvent
// old style swipe event
-(void) swipeWithEvent:(NSEvent *)event
{
    NSLog(@"koko!");
    SwipeBehavior behavior = [[PreferenceModal prefForKey:kSwipeBehavior] intValue];
    if (behavior == kSwipeBehaviorOff) return;
    if([event deltaX] == 1.0f && [event deltaY] == 0.0f){
        if(behavior == kSwipeBehaviorSwitchPage){
            [_delegate swipeBy:1];
        }else if(behavior == kSwipeBehaviorSwitchDictionary){
            [_delegate switchDictionaryBy:1];
        }
    }else if([event deltaX] == -1.0f && [event deltaY] == 0.0f){
        if(behavior == kSwipeBehaviorSwitchPage){
            [_delegate swipeBy:-1];
        }else if(behavior == kSwipeBehaviorSwitchDictionary){
            [_delegate switchDictionaryBy:-1];
        }

    }
}


//-- getCachingView
// 
-(NSBitmapImageRep*) getBitmapImageRepForCachingDisplay
{
    NSBitmapImageRep* image = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:image];
    
    return image;
}


//--

-(BOOL) respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector];
}
@end
