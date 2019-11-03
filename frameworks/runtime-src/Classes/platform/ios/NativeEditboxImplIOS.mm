#import <UIKit/UIKit.h>

#include "../NativeEditbox.h"
#include "platform/CCPlatformConfig.h"
#include "base/CCDirector.h"
#include "base/ccUTF8.h"
#include "platform/ios/CCEAGLView-ios.h"

#define getEditImpl() ((cocos2d::caesars::NativeEditbox*)_box)

@interface NativeUIEditboxImpl: NSObject <UITextFieldDelegate, UITextViewDelegate>{
    void* _box;
    NSString* _editText;
    NSString* _editBaseText;
    BOOL _editing;
    CGFloat _baseFontSize;
    
    UITapGestureRecognizer* _tap;
    UITextField* _textFieldBase;
    UIView* _bgView;
    UITextField* _textField;
    UIButton* _sureBtn;
    UIButton* _cancelBtn;
}

- (void)openKeyboard;
- (void)closeKeyboard;
- (id)initWithEditbox:(void*) box;

@end

@implementation NativeUIEditboxImpl

- (id) initWithEditbox:(void *)box{
    if ( self = [super init] ){
        _box = box;
        _editText = nil;
        _editBaseText = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        _baseFontSize = 30 * size.width / 1334;
        if(_baseFontSize > 30 * size.height / 750)
            _baseFontSize = 30 * size.height / 750;
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(_bgView){
        [self closeKeyboard];
    }
    if(_editBaseText){
        [_editBaseText release];
        _editBaseText = nil;
    }
    if(_editText){
        [_editText release];
        _editText = nil;
    }
    [super dealloc];
}

- (UIView *)findKeyboard
{
    UIView *keyboardView = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [windows reverseObjectEnumerator])//逆序效率更高，因为键盘总在上方
    {
        keyboardView = [self findKeyboardInView:window];
        if (keyboardView)
        {
            return keyboardView;
        }
    }
    return nil;
}
- (UIView *)findKeyboardInView:(UIView *)view
{
    for (UIView *subView in [view subviews])
    {
        if (strstr(object_getClassName(subView), "UIKeyboard"))
        {
            return subView;
        }
        else
        {
            UIView *tempView = [self findKeyboardInView:subView];
            if (tempView)
            {
                return tempView;
            }
        }
    }
    return nil;
}

-(void)openKeyboard{
    //self.isFirst=YES;
    CGSize size = [UIScreen mainScreen].bounds.size;
    if(_bgView == nil){
        auto view = cocos2d::Director::getInstance()->getOpenGLView();
        CCEAGLView *eaglview = (CCEAGLView *)view->getEAGLView();
        
        _textFieldBase = [[UITextField alloc] init];
        [eaglview addSubview:_textFieldBase];
        
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSure:)];
        _tap.cancelsTouchesInView = NO;
        [eaglview addGestureRecognizer:_tap];
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, _baseFontSize + 30)];
        _bgView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.placeholder = [NSString stringWithUTF8String:getEditImpl()->getPlaceHolder()];
        [_textField setFont:[UIFont systemFontOfSize:_baseFontSize]];
    
        //self.clearButton=[[UIButton alloc] init];
        _sureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sureBtn retain];
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelBtn retain];
        
        [_sureBtn setTitle:[NSString stringWithUTF8String:getEditImpl()->getSureBtnText()] forState:UIControlStateNormal];
        [_cancelBtn setTitle:[NSString stringWithUTF8String:getEditImpl()->getCancelBtnText()] forState:UIControlStateNormal];
        [_sureBtn.titleLabel setFont:[UIFont systemFontOfSize:_baseFontSize]];
        [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:_baseFontSize]];
        //[self.clearButton addTarget:self action:@selector(touchUp:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_sureBtn addTarget:self action:@selector(onSure:) forControlEvents: UIControlEventTouchUpInside];
        [_cancelBtn addTarget:self action:@selector(onCancel:) forControlEvents: UIControlEventTouchUpInside];
        [_bgView addSubview: _textField];
        //[inputview addSubview:self.clearButton];
        [_bgView addSubview: _sureBtn];
        [_bgView addSubview: _cancelBtn];
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_textField setDelegate:self];
        _textFieldBase.inputAccessoryView = _bgView;
        
        int returnKeyType = getEditImpl()->getReturnType();
        if(returnKeyType == 0)
            [_textField setReturnKeyType:UIReturnKeyDefault];
        else if(returnKeyType == 1)
            [_textField setReturnKeyType:UIReturnKeyDone];
        else if(returnKeyType == 2)
            [_textField setReturnKeyType:UIReturnKeySend];
        else if(returnKeyType == 3)
            [_textField setReturnKeyType:UIReturnKeySearch];
        else if(returnKeyType == 4)
            [_textField setReturnKeyType:UIReturnKeyGo];
        else if(returnKeyType == 5)
            [_textField setReturnKeyType:UIReturnKeyNext];
        
        int inputFlag = getEditImpl()->getInputFlag();
        if(inputFlag == 0){
            _textField.secureTextEntry = YES;
        }
        else if(inputFlag == 1)
            _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        else if(inputFlag == 2)
            _textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        else if(inputFlag == 3)
            _textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        else if(inputFlag == 4)
            _textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        else if(inputFlag == 5)
            _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        int inputMode = getEditImpl()->getInputMode();
        if(inputMode == 0){
            
        }
        else if(inputMode == 1){
            _textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        else if(inputMode == 2)
            _textField.keyboardType = UIKeyboardTypeDecimalPad; //UIKeyboardTypeNumberPad may cause bug in IR version
        else if(inputMode == 3)
            _textField.keyboardType = UIKeyboardTypePhonePad;
        else if(inputMode == 4)
            _textField.keyboardType = UIKeyboardTypeURL;
        else if(inputMode == 5)
            _textField.keyboardType = UIKeyboardTypeDecimalPad;
        else
            _textField.keyboardType = UIKeyboardTypeDefault;
    }
    if(_editBaseText != nil)
       [_editBaseText release];
    _editBaseText = _editText;
    [_editBaseText retain];
    [self setNativeText:[_editText UTF8String]];
    _editing = YES;
    [_textFieldBase becomeFirstResponder];
    [_textField becomeFirstResponder];
}

-(void)closeKeyboard{
    _editing = NO;
    [_textField release];
    [_sureBtn release];
    [_cancelBtn release];
    [_bgView release];
    [_textFieldBase.superview removeGestureRecognizer:_tap];
    [_textFieldBase removeFromSuperview];
    [_tap release];
    [_textFieldBase release];
    _tap = nil;
    _bgView = nil;
    _textField = nil;
    _sureBtn = nil;
    _cancelBtn = nil;
    _textFieldBase = nil;
}

-(void)textFieldDidChange:(UITextField *)textField
{
    if(_editText != nil)
       [_editText release];
    _editText = textField.text;
    [_editText retain];
    if([_editText length] > 0){
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    else{
        _textField.clearButtonMode = UITextFieldViewModeNever;
    }
    
    getEditImpl()->editBoxEditingChanged([_editText UTF8String]);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    getEditImpl()->editBoxEditingDidBegin();
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(!_editing)
        return;
    if(_editText != nil)
        [_editText release];
    _editText = textField.text;
    [_editText retain];
    
    getEditImpl()->editBoxEditingDidEnd([_editText UTF8String]);
    [self closeKeyboard];
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason NS_AVAILABLE_IOS(10_0){
    [self textFieldDidEndEditing:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([string containsString:@"\n"]){
        [self onSure:textField];
        return NO;
    }
    int maxLength = getEditImpl()->getMaxLength();
    if (maxLength < 0) {
        return YES;
    }
    NSString* tempString = [_editText stringByReplacingCharactersInRange:range withString:string];
    if(strlen([tempString UTF8String]) > maxLength)
        return NO;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self onSure:textField];
    return NO;
}

- (CGSize)sizeForNoticeTitle:(NSString*)text font:(UIFont*)font{
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat maxWidth = screen.size.width;
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGSize textSize = CGSizeZero;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByCharWrapping];
        NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
        CGRect rect = [text boundingRectWithSize:maxSize
                                         options:opts
                                      attributes:attributes
                                         context:nil];
        textSize = rect.size;
    } else{
        NSDictionary *dic = @{NSFontAttributeName : font};
        CGRect infoRect =   [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
        textSize = infoRect.size;
    }
    return textSize;
}

-(void)willShow: (NSNotification *)notice{
    if(_textField == nil || _textFieldBase == nil)
        return;
    if(![_textFieldBase isFirstResponder] && ![_textField isFirstResponder])
        return;
    //NSDictionary *userInfo = [notice userInfo];
    //NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    //CGRect keyboardRect = [aValue CGRectValue];
    CGSize size = [UIScreen mainScreen].bounds.size;
    int offsetX = 10;
    int offsetY = 10;
    int width = size.width - 20;
    if (size.width / size.height > 2.16f) {
        offsetX = offsetX + 0.04f * size.width;
        width = width - 0.08f * size.width;
    }
    _bgView.frame = CGRectMake(0, 0, size.width, _baseFontSize + 30);
    CGSize _cancelSize = [self sizeForNoticeTitle:[NSString stringWithUTF8String:getEditImpl()->getCancelBtnText()] font:[UIFont systemFontOfSize:_baseFontSize]];
    _cancelBtn.frame=CGRectMake(offsetX + width - _cancelSize.width, offsetY, _cancelSize.width, _baseFontSize+10);
    CGSize _sureSize = [self sizeForNoticeTitle:[NSString stringWithUTF8String:getEditImpl()->getSureBtnText()] font:[UIFont systemFontOfSize:_baseFontSize]];
    _sureBtn.frame=CGRectMake(offsetX + width - _cancelSize.width - 10 - _sureSize.width, offsetY, _sureSize.width, _baseFontSize+10);
    _textField.frame=CGRectMake(offsetX, offsetY, width-20-_sureSize.width-_cancelSize.width, _baseFontSize+10);
}

-(void)onSure:(id)sender
{
    [_textField resignFirstResponder];
    [_textFieldBase resignFirstResponder];
    //    [self.textView removeFromSuperview];
    [self closeKeyboard];
    //[self removeFromSuperview];
    //    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
}

-(void)onCancel:(id)sender{
    if(_editText)
        [_editText release];
    _editText = _editBaseText;
    [_editText retain];
    [_textFieldBase setText:_editBaseText];
    [_textField setText:_editBaseText];
    [self onSure:sender];
}

-(void)setNativeText:(const char*)text{
    NSString* newText = [NSString stringWithUTF8String:text];
    if(_editText)
        [_editText release];
    _editText = newText;
    [_editText retain];
    [_textFieldBase setText:newText];
    [_textField setText:newText];
    if([_editText length] > 0){
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    else{
        _textField.clearButtonMode = UITextFieldViewModeNever;
    }
}

@end

NS_CS_BEGIN

class NativeEditboxImplIOS : public NativeEditboxImpl {
public:
	NativeEditboxImplIOS(NativeEditbox* box);
	virtual ~NativeEditboxImplIOS();

	virtual void openKeyboard();
	virtual void closeKeyboard();
protected:
	virtual void setText(const char* pText);
	virtual void doAnimationWhenKeyboardMove(float duration, float distance);

private:
    NativeUIEditboxImpl* _uiBox;
	NativeEditbox* _box;
    float realDis;
};

NativeEditboxImpl* __createPlatformEditboxImpl(NativeEditbox* box) {
	NativeEditboxImplIOS* impl = new NativeEditboxImplIOS(box);
	return impl;
}

NativeEditboxImplIOS::NativeEditboxImplIOS(NativeEditbox* box) {
	_box = box;
    _uiBox = [[NativeUIEditboxImpl alloc] initWithEditbox:(void*)_box];
}

NativeEditboxImplIOS::~NativeEditboxImplIOS() {
    if(_uiBox){
        [_uiBox release];
        _uiBox = nil;
    }
}
void NativeEditboxImplIOS::setText(const char* pText)
{
    [_uiBox setNativeText: pText];
}

void NativeEditboxImplIOS::doAnimationWhenKeyboardMove(float dt, float dis) {

    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *)view->getEAGLView();
    [eaglview doAnimationWhenKeyboardMoveWithDuration:dt distance:dis];
}

void NativeEditboxImplIOS::openKeyboard()
{
    [_uiBox openKeyboard];
}

void NativeEditboxImplIOS::closeKeyboard()
{
    [_uiBox closeKeyboard];
}

NS_CS_END
