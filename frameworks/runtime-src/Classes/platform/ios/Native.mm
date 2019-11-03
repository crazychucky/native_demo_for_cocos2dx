 //
//  Native.mm
//  nozomi
//
//  Created by  stc on 13-5-4.
//
//

#include "platform/Native.h"
#include "platform/ios/CSAlertView.h"
#include "platform/ios/CaeWebView.h"
#include <StoreKit/StoreKit.h>
#import <AdSupport/AdSupport.h>
#import <AudioToolbox/AudioToolbox.h>

#include <UserNotifications/UserNotifications.h>

#include "platform/CCApplication.h"
#include "base/CCDirector.h"
#include "base/CCEventDispatcher.h"
#include "base/CCEventCustom.h"
#include "base/ccUTF8.h"

#import  "ImagePickerViewController.h"
#import  "RootViewController.h"

#include <string>

USING_CS;

#define PICK_IMAGE_EVENT   "ImagePickerEvent"

// pick photo,take photo use the same handler
ScriptCallback* _photoHander = nullptr;

Native::Native(void)
{
    auto dispatcher = cocos2d::Director::getInstance()->getEventDispatcher();
    dispatcher->addCustomEventListener(PICK_IMAGE_EVENT, [=](EventCustom* eve)
    {
        std::string* path = (std::string*)eve->getUserData();
        if (path && _photoHander != nullptr)
        {
            LuaValueArray params;
            auto s = LuaValue::stringValue(*path);
            params.push_back(s);
            _photoHander->executeCallback(params);
        }
    });
}

void Native::openURL(const char *url)
{
    if(strcmp(url,"notification")==0)
    {
        if ([[UIDevice currentDevice].systemVersion floatValue]>=10.0) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"request authorization succeeded!");
                }
            }];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0) {
            UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else{
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
        }
        return;
    }
    NSString *urlStr = [NSString stringWithUTF8String:url];
    NSRange findRange = [urlStr rangeOfString:@"https://www.facebook.com/profile.php?id="];
    if (findRange.length>0)
    {
        NSString* fbUrlStr = [NSString stringWithFormat:@"fb://profile/%@",[urlStr substringFromIndex:findRange.length]];
        NSURL* fbUrl = [NSURL URLWithString:fbUrlStr];
        if ([[UIApplication sharedApplication] canOpenURL:fbUrl]) {
            if ([[UIDevice currentDevice].systemVersion floatValue]>=10.0) {
                [[UIApplication sharedApplication] openURL:fbUrl options:@{} completionHandler:nil];
            }
            else{
                [[UIApplication sharedApplication] openURL:fbUrl];
            }
            return;
        }
    }
    NSURL* newUrl = [NSURL URLWithString:urlStr];
    if ([[UIDevice currentDevice].systemVersion floatValue]>=10.0) {
        [[UIApplication sharedApplication] openURL:newUrl options:@{} completionHandler:nil];
    }
    else{
        [[UIApplication sharedApplication] openURL:newUrl];
    }
}

void Native::sendEmail(const char *receiver, const char *title, const char *message)
{
    NSString* mail = [NSString stringWithUTF8String:receiver];
    NSString* nTitle = [NSString stringWithUTF8String:title];
    NSString* nMessage = [NSString stringWithUTF8String:message];
    NSString* mailUrl = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", mail, nTitle, nMessage];
    NSURL* newUrl;
    if(@available(iOS 9.0, *)){
        NSLog(@"%@", [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        NSLog(@"%@", [mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
        NSLog(@"%@", [mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]);
        newUrl = [NSURL URLWithString:[mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    }
    else{
        newUrl = [NSURL URLWithString:[mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if(@available(iOS 10.0, *)){
        [[UIApplication sharedApplication] openURL:newUrl options:@{} completionHandler:nil];
    }
    else{
        [[UIApplication sharedApplication] openURL:newUrl];
    }
}

void Native::postNotification(int duration, const char *content)
{
    if(content == nullptr)
        return;
    NSString* body;
    NSString* title = nil;
    NSString* subject = nil;
    BOOL badge = YES;
    NSString* soundPath = nil;
    NSString* notificationId = nil;
    //json
    if(content[0] == '{'){
        NSData* requestData = [NSData dataWithBytes:content length:strlen(content)];
        NSError* error0 = nil;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:&error0];
        if(error0){
            body = [NSString stringWithUTF8String:content];
        }
        else{
            if([jsonData objectForKey:@"badge"]){
                badge = [[jsonData objectForKey:@"badge"] boolValue];
            }
            title = [jsonData objectForKey:@"title"];
            subject = [jsonData objectForKey:@"subject"];
            soundPath = [jsonData objectForKey:@"sound"];
            body = [jsonData objectForKey:@"content"];
            id tempId = [jsonData objectForKey:@"id"];
            if(tempId != nil){
                if([tempId isKindOfClass:[NSNumber class]]){
                    notificationId = [(NSNumber*)tempId stringValue];
                }
                else
                    notificationId = tempId;
            }
        }
    }
    else{
        body = [NSString stringWithUTF8String:content];
    }
    if(@available(iOS 10.0, *)){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            UNMutableNotificationContent *notification = [[UNMutableNotificationContent alloc] init];
            if(title)
                notification.title = title;
            if(subject)
                notification.subtitle = subject;
            notification.body = body;
            if(settings.badgeSetting == UNNotificationSettingEnabled && badge){
                if(notification.badge)
                    notification.badge = [NSNumber numberWithInt: [notification.badge intValue] + 1];
                else
                    notification.badge = [NSNumber numberWithInt:1];
            }
            if(settings.soundSetting == UNNotificationSettingEnabled){
                if(soundPath)
                    notification.sound = [UNNotificationSound soundNamed:soundPath];
                else
                    notification.sound = [UNNotificationSound defaultSound];
            }
            
            UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:duration repeats:NO];
            NSString* requestId = notificationId;
            if(!requestId)
                requestId = [NSString stringWithString:body];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestId
                                                                                  content:notification
                                                                                  trigger:trigger1];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        }];
    }
    else{
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        if (notification!=nil){
            BOOL badgeOk = YES;
            BOOL soundOk = YES;
            NSDate *dt = [NSDate new];
            notification.fireDate=[dt dateByAddingTimeInterval:duration];
            [dt release];
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.alertBody = body;
            notification.alertAction = @"Ok";
            if (@available(iOS 8.0, *)) {
                UIUserNotificationType curType = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
                badgeOk = (curType & UIUserNotificationTypeBadge) > 0;
                soundOk = (curType & UIUserNotificationTypeBadge) > 0;
            }
            if (badgeOk && badge)
            {
                notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber+1;
            }
            if (soundOk)
            {
                if(soundPath)
                    notification.soundName = soundPath;
                else
                    notification.soundName = UILocalNotificationDefaultSoundName;
            }
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            [notification autorelease];
        }
    }
}

void Native::clearLocalNotification()
{
    if(@available(iOS 10.0, *)){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //[center removeAllDeliveredNotifications];
        [center removeAllPendingNotificationRequests];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if(settings.badgeSetting == UNNotificationSettingEnabled){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                });
            }
        }];
        return;
    }
    else
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if(@available(iOS 8.0, *)){
        if (([[UIApplication sharedApplication] currentUserNotificationSettings].types & UIUserNotificationTypeBadge) ==0)
            return;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

const char* Native::getDeviceId(){
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* uuid = [userDefaults stringForKey:@"UUID"];
    if(uuid==nil || [uuid length]<2)
    {
        NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
        [dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        [dictForQuery setValue:@"CaesarsUUID" forKey:(id)kSecAttrDescription];
        [dictForQuery setValue:@"CaesarsUUID" forKey:(id)kSecAttrGeneric];
        [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
        [dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        [dictForQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        OSStatus queryErr = noErr;
        NSData* uuidData = nil;
        queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, (CFTypeRef*)&uuidData);
        
        if(queryErr!=errSecSuccess)
        {
            if(queryErr!=errSecItemNotFound)
            {
                NSLog(@"Keychain Item querry Error!!! Error code:%d", (int)queryErr);
            }
        }
        else{
            if(uuidData)
            {
                uuid = [[[NSString alloc] initWithData:uuidData encoding:NSUTF8StringEncoding] autorelease];
                [uuidData release];
                [userDefaults setObject:uuid forKey:@"UUID"];
            }
        }
        [dictForQuery release];
    }
    if(uuid==nil || [uuid length]<2)
    {
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0)
        {
            uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        else{
            CFUUIDRef uuidRef = CFUUIDCreate(nil);
            CFStringRef uuidString = CFUUIDCreateString(nil, uuidRef);
            uuid = (NSString *)CFStringCreateCopy(NULL, uuidString);
            CFRelease(uuidRef);
            CFRelease(uuidString);
            [uuid autorelease];
        }
        [userDefaults setObject:uuid forKey:@"UUID"];
        
        NSMutableDictionary *dictForAdd = [[NSMutableDictionary alloc] init];
        [dictForAdd setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        [dictForAdd setValue:@"CaesarsUUID" forKey:(id)kSecAttrDescription];
        [dictForAdd setValue:@"CaesarsUUID" forKey:(id)kSecAttrGeneric];
        [dictForAdd setObject:@"" forKey:(id)kSecAttrAccount];
        [dictForAdd setObject:@"" forKey:(id)kSecAttrLabel];
        NSData* keychainData = [uuid dataUsingEncoding:NSUTF8StringEncoding];
        [dictForAdd setValue:keychainData forKey:(id)kSecValueData];
        OSStatus writeErr = noErr;
        writeErr = SecItemAdd((CFDictionaryRef)dictForAdd, NULL);
        if(writeErr!=errSecSuccess){
            NSLog(@"Add Keychain Item Error!!! Error Code:%d", (int)writeErr);
        }
        [dictForAdd release];
    }
    return [uuid UTF8String];
}

static std::string s_deviceInfo = "";
const char* Native::getDeviceInfo()
{
    if (s_deviceInfo.empty())
    {
        NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSDictionary* infoDict2 = [[NSBundle mainBundle] localizedInfoDictionary];
        NSString* gameName = [infoDict2 valueForKey:@"CFBundleDisplayName"];
        NSString* fstring = [NSString stringWithFormat:@"{\"deviceId\": \"%s\", \"country\": \"%@\", \"language\": \"%@\", \"platform\": \"%s\", \"model\": \"%@\", \"version\": %.2f, \"name\": \"%@\"}", Native::getDeviceId(), country, language, "ios", [[UIDevice currentDevice] model], [[[UIDevice currentDevice] systemVersion] floatValue], gameName];
        if ( [[UIDevice currentDevice].systemVersion floatValue] < 10.0 || ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0 && [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) ){
            NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            fstring=[NSString stringWithFormat:@"%@, \"adId\": \"%@\"}",[fstring substringToIndex:[fstring length]-1],idfa];
            NSLog(@"fstring:%@",fstring);
        }
        s_deviceInfo = std::string([fstring UTF8String]);
    }
    return s_deviceInfo.c_str();
}

void Native::pasteBoardString(const char *content)
{
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    [pb setString:[NSString stringWithUTF8String:content]];
}

void Native::showLocalRate()
{
    if ([[UIDevice currentDevice].systemVersion floatValue]>=10.3) {
        [SKStoreReviewController requestReview];
    }
}
	
void Native::keepAwaken(bool isAwaken)
{
    if(isAwaken){
        //阻止屏幕变暗。谨慎使用,缺省为no 2.0
        [UIApplication sharedApplication].idleTimerDisabled =YES;
    }else{
        [UIApplication sharedApplication].idleTimerDisabled =NO;
    }
}

void Native::shakeTime(int millions)
{
    /*
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
        UIImpactFeedbackStyle style = UIImpactFeedbackStyleLight;
        if(millions >= 500){
            style = UIImpactFeedbackStyleHeavy;
        }
        else if(millions >= 100)
            style = UIImpactFeedbackStyleMedium;
        UIImpactFeedbackGenerator* impactLight = [[[UIImpactFeedbackGenerator alloc] initWithStyle:style] autorelease];
        [impactLight impactOccurred];
    }
    else{
     */
        // 老版本的不考虑啦，因为这个据说是非公开调用
        /*
        if(millions >= 500)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        else if(millions >= 100)
            AudioServicesPlaySystemSound(1521);
        else
            AudioServicesPlaySystemSound(1520);
         */
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //}
}

void Native::pickPhoto(ScriptCallback* nHandler) {
    CC_SAFE_RELEASE(_photoHander);
    _photoHander = nHandler;
    if(_photoHander!=nullptr)
        _photoHander->retain();

    ImagePickerViewController* imagePickerViewController = [[ImagePickerViewController alloc] initWithNibName:nil bundle:nil];
    
    RootViewController* _viewController = (RootViewController*)m_viewController;
    [_viewController.view addSubview:imagePickerViewController.view];
    
    [imagePickerViewController localPhoto];
}

void Native::takePhoto(ScriptCallback* nHandler) {
    CC_SAFE_RELEASE(_photoHander);
    _photoHander = nHandler;
    if(_photoHander!=nullptr)
        _photoHander->retain();

    ImagePickerViewController* imagePickerViewController = [[ImagePickerViewController alloc] initWithNibName:nil bundle:nil];
    
    RootViewController* _viewController = (RootViewController*)m_viewController;
    [_viewController.view addSubview:imagePickerViewController.view];
    
    [imagePickerViewController takePhoto];
}

void Native::clearPhotoCallback() {
    CC_SAFE_RELEASE(_photoHander);
    _photoHander = nullptr;
}

void  ImagePicker::setViewController(void* viewController)
{
    m_viewController = viewController;
}
