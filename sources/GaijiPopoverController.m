//
//  GaijiPopoverController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "GaijiPopoverController.h"
#import "PreferenceModal.h"

@interface GaijiPopoverController ()

@end

@implementation GaijiPopoverController

- (instancetype)init
{
    self = [super initWithNibName:@"GaijiPopover" bundle:nil];
    if (self) {
        [self loadView];
        
        [_alternativeString bind:@"fontName"
                        toObject:[PreferenceModal sharedPreference]
                       withKeyPath:kContentsFont
                           options:[NSDictionary dictionaryWithObject:@"FontNameToFontFamilyTransformer"
                                                               forKey:@"NSValueTransformerName"]];
    }
    return self;
}



-(IBAction)closePopover:(id)sender{
    [self closePopover];
}


-(void) closePopover
{
    if(_popover){
        [_popover close];
    }
}


-(void) showPopoverRelativeToRect:(NSRect)rect ofView:(NSView*)view
{
    if(_popover){
        [_popover showRelativeToRect:rect ofView:view preferredEdge:NSMaxYEdge];
    }
}
@end
