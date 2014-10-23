//
//  GaijiViewController.h
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ContentsController;

@interface GaijiViewController : NSViewController {
    NSView* _overView;
}


@property (weak, nonatomic) IBOutlet NSTextField* charactorCodeString;
@property (weak, nonatomic) ContentsController* contentsController;


-(instancetype) initWithOverView:(NSView*) textview;


-(IBAction) closeCharactorCodePane:(id) sender;
-(IBAction) changeCharactorCode:(id) sender;

-(void) showCharactorCodePane;
-(void) closeCharactorCodePane;

@end


