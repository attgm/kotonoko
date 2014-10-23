//	PasteboardWatcher.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PasteboardWatcher : NSObject {
	NSTimer* _poolingTimer;
	NSInteger _lastChangeCount;
	
	id _delegate;
}
@property (strong, nonatomic) id delegate;


-(id) initWithDelegate:(id) delegate;
-(void) dealloc;

-(void) startTimer;
-(void) stopTimer;

-(void) checkPasteboard:(NSTimer*) timer;
-(void) checkBackgroundPasteboard;
-(void) observeValueForKeyPath : (NSString *) keyPath
					  ofObject : (id) object
						change : (NSDictionary *) change
					   context : (void *) context;

@end
