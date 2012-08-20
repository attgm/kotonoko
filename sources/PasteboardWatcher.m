//	PasteboardWatcher.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "EBookController.h"
#import "PasteboardWatcher.h"
#import "PreferenceModal.h"

@interface PasteboardWatcher()
@end

void* kUseBPSBindingIdentifier = (void*) @"useBPS";

@implementation PasteboardWatcher
@synthesize delegate = _delegate;

//-- initWithDelegate
// 初期化
-(id) initWithDelegate:(id) delegate
{
	self = [super init];
	if(self){
        _poolingTimer = nil;
        _lastChangeCount = 0;
        self.delegate = delegate;
        
        [[PreferenceModal sharedPreference] addObserver:self
                                             forKeyPath:kUseBackgroundPastebordSearch
                                                options:NSKeyValueObservingOptionNew
                                                context:kUseBPSBindingIdentifier];
        [[PreferenceModal sharedPreference] addObserver:self
                                             forKeyPath:kUsePasteboardSearch
                                                options:NSKeyValueObservingOptionNew
                                                context:kUseBPSBindingIdentifier];
        [self checkBackgroundPasteboard];
	}
	return self;
}


//-- dealloc
// あとかたずけ
-(void) dealloc
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kUseBackgroundPastebordSearch];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kUsePasteboardSearch];
    self.delegate = nil;
    
	[super dealloc];
}


//-- startTimer
// 監視タイマーの開始
-(void) startTimer
{
    if(!_poolingTimer){
        _poolingTimer =
			[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkPasteboard:) userInfo:nil repeats:YES];
		_lastChangeCount = [[NSPasteboard generalPasteboard] changeCount];
	}
}



//-- stopTimer
// 監視タイマーの停止
-(void) stopTimer
{
	if(_poolingTimer){
		[_poolingTimer invalidate];
		_poolingTimer = nil;
	}
}


//-- chechPasteboard
// ペーストボードの中身の確認
-(void) checkPasteboard:(NSTimer*) timer 
{
	NSInteger changeCount = [[NSPasteboard generalPasteboard] changeCount];
	if (changeCount == _lastChangeCount) return;
	if(![NSApp isActive]){
		[self.delegate searchPasteboardString];
	}
	_lastChangeCount = changeCount;
}


#pragma mark Observer
//-- checkBackgroundPasteboard
// 
-(void) checkBackgroundPasteboard
{
	if([[PreferenceModal prefForKey:kUseBackgroundPastebordSearch] boolValue]
	   && [[PreferenceModal prefForKey:kUsePasteboardSearch] boolValue]){
		[self startTimer];
	}else{
		[self stopTimer];
	}
}



//-- observeValueForKeyPath:ofObject:change:context:
//
-(void) observeValueForKeyPath : (NSString *) keyPath
					  ofObject : (id) object
						change : (NSDictionary *) change
					   context : (void *) context
{
	if(context == kUseBPSBindingIdentifier){
		[self checkBackgroundPasteboard];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}
@end
