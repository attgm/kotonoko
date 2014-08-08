//
//  PlayerViewController.m
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "PlayerViewController.h"
#import "PreferenceModal.h"


@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (instancetype)init
{
    self = [super initWithNibName:@"MoviePanel" bundle:nil];
    if (self) {
        _player = nil;
    }
    return self;
}

- (void) dealloc
{
    if(_player){ [_player dealloc]; }
    [super dealloc];
}

//-- showMoviePanel
// movie用のパネルを表示する
-(void) playMovie:(NSString *)path
             over:(NSView *)textview
{
    [self loadView];
    if(!_player){ _player = [[AVPlayer alloc] init]; }
    
    AVAsset* asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path isDirectory:NO]];
    [asset loadValuesAsynchronouslyForKeys:nil completionHandler:^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            CGSize size = ([tracks count] > 0) ? [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize] : NSMakeSize(80  , 80);
            
            //NSSize size = [[movie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
            
            //NSRect controlBound = [_playerView con]
            //[_qtView setMovie:movie];
            //NSRect qtRect = [_qtView frame];
            //NSRect controlBound = [_qtView movieControllerBounds];
            
            NSRect playerRect = [_playerView frame];
            
            if (size.width == 0) size.width = 240;
            //size.height += controlBound.size.height;
            CGFloat movieHeight = size.height + 32;
            playerRect.size = size;
            
            CGFloat currentHeight = 0;
            if([self.view superview] == nil){
                [[textview superview] addSubview:self.view];
                currentHeight = 0;
            }else{
                currentHeight = self.view.frame.size.height;
            }
            
            NSRect movieRect = [self.view frame];
            NSRect contentsRect = [textview frame];
            
            movieRect.size.height = movieHeight;
            contentsRect.size.height -= (movieRect.size.height - currentHeight);
            movieRect.size.width = contentsRect.size.width;
            movieRect.origin.x = 0; movieRect.origin.y = contentsRect.size.height + contentsRect.origin.y;
            [self.view setFrame:movieRect];
            [textview setFrame:contentsRect];
             
            //movieRect.origin.x = round((movieRect.size.width - size.width) / 2);
            //movieRect.origin.y = 0;
            //[_playerView setFrame:movieRect];
             
            [self.view setNeedsDisplay:YES];
            
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            [_player replaceCurrentItemWithPlayerItem:playerItem];
            _playerView.player = _player;
            
            if([PreferenceModal prefForKey:kPlaySoundAutomatically]){
                [_player play];
            }
        });
    }];

    
}

//--- closePanal
//
-(void) closePanel:(NSView *)textview
{
    if([self.view superview] != nil){
        [_player pause];
        [_player replaceCurrentItemWithPlayerItem:nil];
        NSRect movieRect = [self.view frame];
        NSRect contentsRect = [textview frame];
    
        contentsRect.size.height += movieRect.size.height;
        [textview setFrame:contentsRect];
        [self.view removeFromSuperview];
    }
}

@end
