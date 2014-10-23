//
//  GaijiViewController.m
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "GaijiViewController.h"
#import "PreferenceModal.h"
#import "ContentsController.h"

@interface GaijiViewController ()

@end

@implementation GaijiViewController

-(instancetype) initWithOverView:(NSView*) textview
{
    self = [super initWithNibName:@"GaijiPanel" bundle:nil];
    if (self) {
        [self loadView];
        
        _overView = textview;
        [_charactorCodeString bind:@"fontName"
                          toObject:[PreferenceModal sharedPreference]
                       withKeyPath:kContentsFont
                           options:[NSDictionary dictionaryWithObject:@"FontNameToFontFamilyTransformer"
                                                               forKey:@"NSValueTransformerName"]];
    }
    return self;
}


//-- showCharactorCodePane
//
-(void) showCharactorCodePane
{
    if([self.view superview] == nil){
        NSRect ccRect = [self.view frame];
        NSRect svRect = [_overView frame];
        svRect.size.height -= ccRect.size.height;
        svRect.origin.y += ccRect.size.height;
        ccRect.size.width = svRect.size.width;
        ccRect.origin.x = ccRect.origin.y = 0;
        [[_overView superview] addSubview:self.view];
        [self.view setFrame:ccRect];
        [_overView setFrame:svRect];
    }
    [self.view setNeedsDisplay:YES];
    [[_charactorCodeString window] makeFirstResponder:_charactorCodeString];
}



//-- closeCharactorCodePane
// 外字paneを閉じる
-(IBAction) closeCharactorCodePane:(id) sender
{
    [self closeCharactorCodePane];
}


//-- changeCharactorCode
-(IBAction) changeCharactorCode:(id) sender
{
    if(_contentsController){
        [_contentsController reloadContents];
    }
}


//-- closeCharactorCodePane
// 外字Paneを閉じる
-(void) closeCharactorCodePane
{
    if([self.view superview]){
        NSRect ccRect = [self.view frame];
        NSRect svRect = [_overView frame];
        svRect.size.height += ccRect.size.height;
        svRect.origin.y = 0;
        [_overView setFrame:svRect];
        
        [self.view removeFromSuperview];
    }
}

@end
