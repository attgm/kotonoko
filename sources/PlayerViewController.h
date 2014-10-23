//
//  PlayerViewController.h
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>


@interface PlayerViewController : NSViewController {
    AVPlayer* _player;
}

@property (weak, nonatomic) IBOutlet AVPlayerView* playerView;

-(instancetype) init;
-(void) playMovie:(NSString*)path over:(NSView*)textview;

-(void) closePanel:(NSView*) textview;
@end
