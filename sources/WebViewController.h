//
//  WebViewController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class ContentsHistory;

@interface WebViewController : NSViewController

@property (weak, nonatomic) IBOutlet WebView* webview;
@property (strong, nonatomic) ContentsHistory* history;
@property (weak, nonatomic, setter=setIndicator:) NSProgressIndicator* indicator;

-(instancetype) init;

-(void) stopLoading;
-(void) loadURL:(NSURL*) url;

-(void) searchInContent:(NSString*) word;
-(NSArray*) webFrames;
-(void) addWebFramesWithParent:(WebFrame*)webFrame inArray:(NSMutableArray*)array;

-(void) webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame;
-(void)	webView:(WebView*)sender didFailLoadWithError:(NSError*)error forFrame:(WebFrame *)frame;
-(void) webView:(WebView*)webView didFailProvisionalLoadWithError:(NSError*)error forFrame:(WebFrame*)frame;
-(void) showErrorPage:(NSError*)error forFrame:(WebFrame*)frame;
-(NSString*) createErrorHtml:(NSError*) error;


-(void) webView:(WebView*) sender decidePolicyForNavigationAction:(NSDictionary*) info request:(NSURLRequest*) request frame:(WebFrame*) frame decisionListener:(id <WebPolicyDecisionListener >) listener;

@end



@interface WebViewAnimation : NSAnimation

@property (weak, atomic) WebView* webview;
@property (assign, readonly) CGFloat endScale;
@property (assign, readonly) CGFloat startScale;

-(id)initWithWebView:(WebView*)webview scale:(CGFloat)scale duration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve;
-(void)setCurrentProgress:(NSAnimationProgress)progress;

@end;