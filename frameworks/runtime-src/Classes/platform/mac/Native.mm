 //
//  Native.mm
//  nozomi
//
//  Created by  stc on 13-5-4.
//
//

#include "platform/Native.h"
#include <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>

USING_CS;

void Native::openURL(const char *url)
{
    NSString *urlStr = [NSString stringWithUTF8String:url];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlStr]];
}

void Native::sendEmail(const char *receiver, const char *title, const char *message)
{
    NSString* mail = [NSString stringWithUTF8String:receiver];
    NSString* nTitle = [NSString stringWithUTF8String:title];
    NSString* nMessage = [NSString stringWithUTF8String:message];
    NSString* mailUrl = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", mail, nTitle, nMessage];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

void Native::postNotification(int duration, const char *content)
{
    
}

void Native::clearLocalNotification()
{
    
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
            CFUUIDRef uuidRef = CFUUIDCreate(nil);
            CFStringRef uuidString = CFUUIDCreateString(nil, uuidRef);
            uuid = (NSString *)CFStringCreateCopy(NULL, uuidString);
            CFRelease(uuidRef);
            CFRelease(uuidString);
            [uuid autorelease];
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

const char* Native::getDeviceInfo()
{
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary* infoDict2 = [[NSBundle mainBundle] localizedInfoDictionary];
    NSString* gameName = [infoDict2 valueForKey:@"CFBundleDisplayName"];
    NSString* fstring = [NSString stringWithFormat:@"{\"deviceId\": \"%s\", \"country\": \"%@\", \"language\": \"%@\", \"platform\": \"%s\", \"model\": \"%@\", \"version\": %.2f, \"name\": \"%@\"}", Native::getDeviceId(), country, language, "ios", @"mac", 6.0, gameName];
    
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 10.0 || ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0 && [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) ){
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        fstring=[NSString stringWithFormat:@"%@, \"adId\": \"%@\"}",[fstring substringToIndex:[fstring length]-1],idfa];
    }
    return [fstring UTF8String];
}

void Native::pasteBoardString(const char *content)
{
}

void Native::showLocalRate()
{
}
