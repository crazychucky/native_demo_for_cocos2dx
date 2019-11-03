//
//  WebView.h
//  nozomi
//
//  Created by  stc on 13-11-25.
//
//
#import <UIKit/UIKit.h>

@protocol WebViewDelegate <NSObject>

@required

-(BOOL)checkRedirectUrl:(NSString*)redirectUrl;
-(void)closeWebView;

@end

@interface CaeWebView : UIView<UIWebViewDelegate>
{
    UIWebView *webView;
    UINavigationBar* bar;
    UIView *modalBackgroundView;
    UIActivityIndicatorView *indicatorView;
    UIInterfaceOrientation previousOrientation;
    
    id<WebViewDelegate> delegate;
    bool closable;
    
    NSString *requestUrl;
}

@property (nonatomic, assign) id<WebViewDelegate> delegate;

- (id)initWithUrl:(NSString*)url andDelegate:(id<WebViewDelegate>)_delegate;

- (void)show;
- (void)hide;
- (void)setClosable:(bool)able;
- (void)setTitle: (NSString*)title;

@end

@interface CSWebView : CaeWebView<WebViewDelegate>
{
    NSString* _closeUrl;
}

- (id)initWithUrl:(NSString*)url andCloseUrl:(NSString*)closeUrl;

-(BOOL)checkRedirectUrl:(NSString*)redirectUrl;
-(void)closeWebView;

@end
