//	EBStyleSheet.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebPreferences;

@interface EBStyleSheet : NSObject {
	WebPreferences* _webPreferences;
}


+(EBStyleSheet*) sharedStyleSheet;

-(id) init;
-(void) registerStyleSheet;

-(WebPreferences*) webPreferences;

-(void) updateStyleSheet;
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
@end
