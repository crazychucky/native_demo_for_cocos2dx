#import "CustomAlertView.h"

@implementation CustomAlertView

@synthesize delegate;

- (void)close
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(clean)];
    self.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void)clean
{
    if(delegate){
        if ([delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
            [delegate alertView:self didDismissWithButtonIndex:buttonIndex];
    }
    [self removeFromSuperview];
}

- (void)customButtonClicked:(id)sender
{
    if(isClosing)
        return;
    buttonIndex = [sender tag];
    isClosing = YES;
    if(delegate){
        if ([delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
            [delegate alertView:self clickedButtonAtIndex:buttonIndex];
    }
    [self close];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)index animated:(BOOL)animated
{
    buttonIndex = index;
    if(delegate){
        if ([delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
            [delegate alertView:self clickedButtonAtIndex:buttonIndex];
    }
    if (animated) {
        [self close];
    }
    else{
        [self clean];
    }
}

- (id)initWithTitle:(NSString*)title content:(UIView*)view cancelButton:(NSString*)btn0 otherButtons:(NSArray*)otherButtons
{
    self = [super init];
    if (self) {
        isClosing = NO;
        isIos7 = [[[UIDevice currentDevice] systemVersion] floatValue]>=7.0f;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.contentMode = UIViewContentModeRedraw;
        
        CGFloat border = 0.0f;
        contentView = view;
        CGRect frame = contentView.frame;
        
        CGFloat buttonHeight = 50.0f;
        CGFloat buttonSpace = 1.0f;
        CGFloat titleHeight = 0.0f;
        CGFloat cornerRadius = 7.0f;
        CGFloat titleSpace = 0.0f;
        titleView = nil;
        self.frame = CGRectMake(0, 0, border*2+frame.size.width, frame.size.height+border*2 + buttonSpace + buttonHeight);
        if(title!=nil&&![@"" isEqualToString:title]){
            titleHeight = buttonHeight;
            titleSpace = buttonSpace;
            
            self.frame = CGRectMake(0, 0, border*2+frame.size.width, frame.size.height+border*2 + 2*(buttonSpace + buttonHeight));
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(border, border, frame.size.width, titleHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.text = title;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            [label setFont:[UIFont boldSystemFontOfSize:14.0f]];
            titleView = label;
            [self addSubview:label];
            [label release];
        }
        contentView.frame = CGRectMake(border, border+titleHeight+titleSpace, frame.size.width, frame.size.height);
        [self addSubview:contentView];
        buttonsView = [[UIView alloc] initWithFrame:CGRectMake(border, border + titleHeight + titleSpace + buttonSpace + frame.size.height, frame.size.width, buttonHeight)];
        NSMutableArray* buttonTitles = [NSMutableArray arrayWithObject:btn0];
        if (otherButtons!=nil)
            [buttonTitles addObjectsFromArray:otherButtons];
        NSUInteger count = [buttonTitles count];
        CGFloat buttonWidth = frame.size.width / count;
        if (isIos7)
        {
            for(int i=0; i<[buttonTitles count]; i++)
            {
                UIButton* alertButton = [UIButton buttonWithType:UIButtonTypeCustom];
                
                alertButton.frame = CGRectMake((count-1-i)*buttonWidth, 0.0f, buttonWidth, buttonHeight);
                [alertButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
                [alertButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
                [alertButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
                [alertButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
                [alertButton.layer setCornerRadius:cornerRadius];
                
                [alertButton addTarget:self action:@selector(customButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                alertButton.tag = i;
                [buttonsView addSubview:alertButton];
            }
        }
        else{
            for(int i=0; i<[buttonTitles count]; i++)
            {
                UIButton* alertButton = [UIButton buttonWithType:UIButtonTypeSystem];
                
                alertButton.frame = CGRectMake((count-1-i)*buttonWidth, 0.0f, buttonWidth, buttonHeight);
                [alertButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
                /*
                [alertButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
                [alertButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
                [alertButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
                [alertButton.layer setCornerRadius:7];
                */
                [alertButton addTarget:self action:@selector(customButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                alertButton.tag = i;
                [buttonsView addSubview:alertButton];
            }
        }
        [self addSubview:buttonsView];
        [buttonsView release];
        
        CAGradientLayer *gra = [CAGradientLayer layer];
        gra.frame = self.bounds;
        CGFloat fc = 218.0f/255.0f;
        CGFloat fc2 = 233.0f/255.0f;
        gra.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:fc green:fc blue:fc alpha:1.0f] CGColor],
                      (id)[[UIColor colorWithRed:fc2 green:fc2 blue:fc2 alpha:1.0f] CGColor],
                      (id)[[UIColor colorWithRed:fc green:fc blue:fc alpha:1.0f] CGColor],nil];
        gra.cornerRadius = cornerRadius;
        [self.layer insertSublayer:gra atIndex:0];
        
        self.layer.cornerRadius = cornerRadius;
        fc = 198.0f/255.0f;
        self.layer.borderColor = [[UIColor colorWithRed:fc green:fc blue:fc alpha:1.0f] CGColor];
        self.layer.borderWidth = 1;
        self.layer.shadowRadius = cornerRadius+5;
        self.layer.shadowOpacity = 0.1f;
        self.layer.shadowOffset = CGSizeMake(0-(cornerRadius+5)/2, 0-(cornerRadius+5)/2);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
        
        UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0, titleHeight + titleSpace + frame.size.height, self.frame.size.width, buttonSpace)] autorelease];
        lineView.backgroundColor = [UIColor colorWithRed:fc green:fc blue:fc alpha:1.0f];
        [self addSubview:lineView];
        
        self.delegate = nil;
    }
    return self;
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

- (void)show
{
    
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGPoint center = CGPointMake(frame.origin.x + ceil(frame.size.width/2),
                                 frame.origin.y + ceil(frame.size.height/2));
    self.center = center;
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    frame = window.frame;
    NSLog(@"%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    [window addSubview:self];
    
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3/1.5];
    //[UIView setAnimationDelegate:self];
    //[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 1.0, 1.0);
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
