//
//  WebViewController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "WebViewController.h"
#import "EBookUtilities.h"
#import "ContentsHistory.h"
#import "NetDictionary.h"

@interface WebHTMLView : NSView <WebDocumentView>
- (NSUInteger)markAllMatchesForText:(NSString *)string caseSensitive:(BOOL)caseFlag limit:(unsigned)limit;
- (void)unmarkAllTextMatches;
- (void)setMarkedTextMatchesAreHighlighted:(BOOL)newValue;
@end

@interface WebView (WebPendingPublic)
@property float pageSizeMultiplier;
-(IBAction)resetPageZoom:(id)sender;
@end

@interface WebViewController ()
@end


@implementation WebViewController

-(instancetype) init
{
    self = [super initWithNibName:@"WebView" bundle:nil];
    if (self) {
    }
    return self;
}

#pragma mark Setter
//-- setIndicator
//
-(void) setIndicator:(NSProgressIndicator *)indicator
{
    if(indicator != _indicator){
        _indicator = indicator;
        [_indicator bind:@"value" toObject:_webview withKeyPath:@"estimatedProgress" options:nil];
    }
}



#pragma mark Mathods
//-- stopLoading
//
-(void) stopLoading
{
    if([self.webview isLoading]){
        [self.webview stopLoading:nil];
        if(_indicator){ [_indicator setHidden:YES]; }
    }
}


//-- loadURL
//
-(void) loadURL:(NSURL*) url
{
    if(_indicator){
        [_indicator setHidden:NO];
    }
    [self.webview resetPageZoom:nil];
    [self.webview.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
}



#pragma mark Search
//-- searchInContent
//
-(void) searchInContent:(NSString*) word
{
    NSEnumerator* e = [[self webFrames] objectEnumerator];
    WebFrame* frame;
    while (frame = [e nextObject]) {
        id  documentView = [[frame frameView] documentView];
        if ([documentView respondsToSelector:@selector(unmarkAllTextMatches)]){
            [documentView unmarkAllTextMatches];
        }
        if ([documentView respondsToSelector:@selector(setMarkedTextMatchesAreHighlighted:)]){
            [documentView setMarkedTextMatchesAreHighlighted:YES];
        }
        if ([documentView respondsToSelector:@selector(markAllMatchesForText:caseSensitive:limit:)]){
            [documentView markAllMatchesForText:word caseSensitive:NO limit:0];
        }
    }
}


//-- webFrames
// webviewに含まれるframeをすべて返す
-(NSArray*) webFrames
{
    NSMutableArray* array = [NSMutableArray array];
    
    [array addObject:self.webview.mainFrame];
    [self addWebFramesWithParent:self.webview.mainFrame inArray:array];
    return array;
}



//-- addWebFramesWithParent:inArray:
//
-(void) addWebFramesWithParent:(WebFrame*)webFrame inArray:(NSMutableArray*)array
{
    [array addObject:webFrame];
    
    NSEnumerator*   e = [[self.webview.mainFrame childFrames] objectEnumerator];
    WebFrame*       frame;
    while (frame = [e nextObject]) {
        [self addWebFramesWithParent:frame inArray:array];
    }
}






#pragma mark WebFrameLoadDelegate
//-- webView:didCommitLoadForFrame:
//
-(void)             webView:(WebView*)sender
      didFinishLoadForFrame:(WebFrame*)frame
{
    
    if ([sender mainFrame] == frame) {
        if(_indicator){ [_indicator setHidden:YES]; }

        NSView* clipView = [[[_webview mainFrame] frameView] documentView];
        NSRect webFrameRect = [clipView bounds];
        NSRect webViewRect = [_webview frame];
        
        CGFloat scale = webViewRect.size.width / webFrameRect.size.width;
        WebViewAnimation* animation = [[[WebViewAnimation alloc] initWithWebView:_webview
                                                                           scale:scale
                                                                        duration:0.2
                                                                  animationCurve:NSAnimationLinear] autorelease];
        [animation setAnimationBlockingMode:NSAnimationNonblocking];
        [animation startAnimation];
    }
}


//-- webView:didFailLoadWithError:forFrame:
// エラー処理
-(void)			 webView:(WebView*)sender
    didFailLoadWithError:(NSError*)error
                forFrame:(WebFrame*)frame
{
    [self showErrorPage:error forFrame:frame];
}


//-- webView:didFailProvisionalLoadWithError:forFrame:
// エラー処理
- (void)					webView:(WebView*)webView
    didFailProvisionalLoadWithError:(NSError*)error
                            forFrame:(WebFrame*)frame
{
    [self showErrorPage:error forFrame:frame];
}



//-- showErrorPage
// エラーページを作成し表示する
-(void) showErrorPage:(NSError*) error
             forFrame:(WebFrame*) frame
{
    if(_indicator){ [_indicator setHidden:YES]; }
    
    NSString* domain = [error domain];
    NSInteger code = [error code];
    if (([domain isEqualToString:NSURLErrorDomain] && code == NSURLErrorCancelled) ||
        ([domain isEqualToString:WebKitErrorDomain] && code == WebKitErrorFrameLoadInterruptedByPolicyChange)){
        return;
    }
    
    NSString* path = MakeHtmlFolder();
    path = [path stringByAppendingPathComponent:@"error.html"];
    NSString* html = [self createErrorHtml:error];
    NSError* err;
    if(![html writeToFile:path atomically:YES encoding:NSUTF8StringEncoding  error:&err]){
        NSLog(@"%@", [err localizedDescription]);
        return;
    }
    [frame loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}



//-- createErrorHtml
// エラー処理
-(NSString*) createErrorHtml:(NSError*) error
{
    NSMutableString* html = [[NSMutableString alloc] init];
    [html appendString:@"<html><head>"
     @"<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>"
     @"<link rel='stylesheet' href='styles.css' type='text/css'>"];
    [html appendFormat:@"<title>%@</title>", [error localizedDescription]];
    [html appendString:@"</head><body><div class=\"error-container\">"];
    [html appendFormat:@"<p class=\"error-title\">%@</p>", [error localizedDescription]];
    if([error localizedRecoverySuggestion]){
        [html appendFormat:@"<p class=\"error-message\">%@</p>", [error localizedRecoverySuggestion]];
    }
    [html appendString:@"</div></body></html>"];
    
    return [html autorelease];
}



#pragma mark WebPolicyDelegate
//-- webView:decidePolicyForNavigationAction:request:frame:decisionListener:
// webページの変更用
- (void)                   webView:(WebView      *) sender
   decidePolicyForNavigationAction:(NSDictionary *) info
                           request:(NSURLRequest *) request
                             frame:(WebFrame     *) frame
                  decisionListener:(id <WebPolicyDecisionListener >) listener
{
    if([[info objectForKey:WebActionNavigationTypeKey] intValue] == WebNavigationTypeLinkClicked){
        NSString* identify = [[_history currentURL] host];
        id dictionary = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:identify];
        if(dictionary && [dictionary isKindOfClass:[NetDictionary class]]){
            if([dictionary isDictionaryHost:[[request URL] host]]){
                [listener use];
                NSURL* historyURL =
                [NSURL URLWithString:[NSString stringWithFormat:@"web://%@/%@", identify, [[request URL] absoluteString]]];
                //[self addLocationHistory:historyURL];
                if([_history currentURL] != historyURL){
                    [_history setCurrentURL:historyURL];
                }
            }else{
                [listener ignore];
                NSDictionary  *asErrDic = nil;
                NSAppleScript *as = [[NSAppleScript alloc] initWithSource:
                                     [NSString stringWithFormat:@"open location \"%@\"", [[request URL] absoluteString]]];
                [as executeAndReturnError:&asErrDic];
                [as autorelease];
            }
            return;
        }
    }
    [listener use];
}

@end



#pragma mark -
#pragma mark WebViewAnimation
@implementation WebViewAnimation
//-- initWithDuration:animationCurve:
//
- (id)initWithWebView:(WebView*)webview
                scale:(CGFloat)scale
             duration:(NSTimeInterval)duration
       animationCurve:(NSAnimationCurve)animationCurve
{
    self = [super initWithDuration:duration animationCurve:animationCurve];
    if(self){
        _webview = webview;
        _endScale = scale;
        if([_webview respondsToSelector:@selector(pageSizeMultiplier)]){
            _startScale = [_webview pageSizeMultiplier];
        }else{
            _startScale = 1.0f;
        }

    }
    return self;
}


//-- setCurrentProgress:
//
- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    [super setCurrentProgress:progress];
    
    if([_webview respondsToSelector:@selector(setPageSizeMultiplier:)]){
        CGFloat scale = progress * (_endScale - _startScale) + _startScale;
        [_webview setPageSizeMultiplier:scale];
    }
}
@end;

