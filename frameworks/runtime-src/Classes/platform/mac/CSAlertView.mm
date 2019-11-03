//
//  CSAlertView.m
//  nozomi
//
//  Created by  stc on 13-8-27.
//
//

#import "CSAlertView.h"

#import "base/CCDirector.h"

@implementation CSAlertView

- (id)initWithTitle:(NSString *)title content:(NSString *)content button1:(int)button1 button1Text:(NSString *)button1Text button2:(int)button2 button2Text:(NSString *)button2Text
{
    if(self = [super init]){
        button[0] = button1;
        button[1] = button2;
        
    }
    return self;
}

@end
