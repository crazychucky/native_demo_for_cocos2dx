#import <UIKit/UIKit.h>

@protocol CustomAlertViewDelegate;

@interface CustomAlertView : UIView
{
    UIView *titleView;
    UIView *buttonsView;
    UIView *contentView;
    
    id<CustomAlertViewDelegate> delegate;
    
    BOOL isIos7;
    BOOL isClosing;
    NSInteger buttonIndex;
}

@property (nonatomic, assign) id<CustomAlertViewDelegate> delegate;

- (id)initWithTitle:(NSString*)title content:(UIView*)view cancelButton:(NSString*)btn0 otherButtons:(NSArray*)otherButtons;

- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)index animated:(BOOL)animated;

@end

@protocol CustomAlertViewDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)alertView:(CustomAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end

