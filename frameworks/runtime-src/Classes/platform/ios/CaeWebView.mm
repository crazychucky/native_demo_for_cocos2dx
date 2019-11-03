//
//  KaixinWebView.m
//  nozomi
//
//  Created by  stc on 13-11-25.
//
//

#import "CaeWebView.h"

static CGFloat kTransitionDuration = 0.3;

@implementation CaeWebView

@synthesize delegate;

#pragma mark - Memory management

- (id)initWithUrl:(NSString*)url andDelegate:(id<WebViewDelegate>)_delegate
{
    if ((self = [super init]))
    {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentMode = UIViewContentModeRedraw;
        
        webView = [[UIWebView alloc] init];
        webView.delegate = self;
        webView.scalesPageToFit = YES;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:webView];
        [webView release];
        
        requestUrl = [url retain];
        
        closable = YES;
        bar = [[UINavigationBar alloc] init];
        bar.autoresizesSubviews = YES;
        bar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
        UINavigationItem* item = [[UINavigationItem alloc] init];
        UIBarButtonItem* button1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:webView action:@selector(goBack)];
        //UIBarButtonItem* button2 = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
        UIBarButtonItem* button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel)];
        [item setLeftBarButtonItem:button1];
        [item setRightBarButtonItem:button2];
        [bar pushNavigationItem:item animated:NO];
        [button1 release];
        [button2 release];
        [item release];
        [self addSubview:bar];
        [bar release];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                         UIActivityIndicatorViewStyleGray];
        indicatorView.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:indicatorView];
        
        modalBackgroundView = [[UIView alloc] init];
        
        self.delegate = _delegate;
    }
    return self;
}

- (void)dealloc
{
    [modalBackgroundView release], modalBackgroundView = nil;
    [requestUrl release], requestUrl = nil;
    [super dealloc];
}

#pragma mark - View orientation

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == previousOrientation)
    {
        return NO;
    }
    else
    {
        return orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown
        || orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight;
    }
}

- (CGAffineTransform)transformForOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        return CGAffineTransformIdentity;
    if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        return CGAffineTransformMakeRotation(M_PI/2);
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return CGAffineTransformMakeRotation(-M_PI);
    }
    else
    {
        return CGAffineTransformIdentity;
    }
}

- (void)sizeToFitOrientation:(BOOL)transform
{
    if (transform)
    {
        self.transform = CGAffineTransformIdentity;
    }
    
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGPoint center = CGPointMake(frame.origin.x + ceil(frame.size.width/2),
                                 frame.origin.y + ceil(frame.size.height/2));
    
    CGFloat scaleFactor = 1.0f;
    
    CGFloat width = floor(scaleFactor * frame.size.width);
    CGFloat height = floor(scaleFactor * frame.size.height);
    
    previousOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        self.frame = CGRectMake(0, 0, width, height);
    }
    else if (UIInterfaceOrientationIsLandscape(previousOrientation))
    {
        self.frame = CGRectMake(0, 0, height, width);
    }
    else
    {
        self.frame = CGRectMake(0, 0, width, height);
    }
    self.center = center;
    
    if (transform)
    {
        self.transform = [self transformForOrientation];
    }
}

- (void)updateWebOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        [webView stringByEvaluatingJavaScriptFromString:
         @"document.body.setAttribute('orientation', 90);"];
    }
    else
    {
        [webView stringByEvaluatingJavaScriptFromString:
         @"document.body.removeAttribute('orientation');"];
    }
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods

- (void)deviceOrientationDidChange:(id)object
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if ([self shouldRotateToOrientation:orientation])
    {
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
}

#pragma mark - Animation

- (void)bounce1AnimationStopped
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation],0.9f,0.9f);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    self.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

#pragma mark Obeservers

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

#pragma mark - Activity Indicator

- (void)showIndicator
{
    [indicatorView sizeToFit];
    [indicatorView startAnimating];
    indicatorView.center = webView.center;
}

- (void)hideIndicator
{
    [indicatorView stopAnimating];
}

#pragma mark - Show / Hide

- (void)show
{
    [self sizeToFitOrientation:NO];
    
    CGFloat innerWidth = self.frame.size.width;
    [bar sizeToFit];
    
    webView.frame = CGRectMake(0, 0, innerWidth,
                               self.frame.size.height);
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]]];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    CGRect frame = window.frame;
    NSLog(@"%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    modalBackgroundView.frame = window.frame;
    [modalBackgroundView addSubview:self];
    [window addSubview:modalBackgroundView];
    
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
    
    [self showIndicator];
    
    [self addObservers];
}

- (void)_hide
{
    [self removeFromSuperview];
    [modalBackgroundView removeFromSuperview];
}

- (void)hide
{
    [self removeObservers];
    
    [webView stopLoading];
    
    [self performSelectorOnMainThread:@selector(_hide) withObject:nil waitUntilDone:NO];
}

- (void)cancel
{
    [delegate closeWebView];
    [self hide];
}

- (void)setClosable:(bool)able
{
    if (closable!=able) {
        closable = able;
        if(closable){
            [bar setHidden:NO];
        }
        else{
            [bar setHidden:YES];
            webView.scrollView.scrollEnabled = NO;
        }
    }
}

- (void)setTitle:(NSString *)title
{
    [bar.topItem setTitle:title];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[self hideIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideIndicator];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    NSLog(@"url = %@", url);
    
    if ([delegate checkRedirectUrl:url])
    {
        [self hide];
        return NO;
    }
    
    [self showIndicator];
    return YES;
}


@end


@implementation CSWebView

- (id)initWithUrl:(NSString*)url andCloseUrl:(NSString *)closeUrl
{
    if ((self = [super initWithUrl:url andDelegate:nil]))
    {
        delegate = self;
        if(closeUrl==nil)
            _closeUrl = [[NSString alloc] initWithString:@""];
        else
            _closeUrl = [[NSString alloc] initWithString:closeUrl];
    }
    return self;
}

- (void)dealloc
{
    [_closeUrl release], _closeUrl = nil;
    [super dealloc];
}

-(BOOL)checkRedirectUrl:(NSString*)redirectUrl
{
    if(![@"" isEqualToString:_closeUrl] && [redirectUrl rangeOfString:_closeUrl].location==0)
    {
        return YES;
    }
    else{
        return NO;
    }
}

-(void)closeWebView
{
    
}

@end
