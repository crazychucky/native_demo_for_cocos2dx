//
//  NativeAlert.m
//  nozomi
//
//  Created by  stc on 14-10-16.
//
//

#include "../NativeAlert.h"
#include <Cocoa/Cocoa.h>

USING_CS;
USING_NS_CC;


@interface LocalAlertDelegate : NSObject
{
    NativeAlert* m_pCallback;
    NSArray* m_listArray;
}

- (id)initWithDictionary:(NSDictionary*)configDict callback:(NativeAlert*)cAlert;

@end

@implementation LocalAlertDelegate

- (id)initWithDictionary:(NSDictionary *)configDict callback:(cocos2d::caesars::NativeAlert *)cAlert
{
    /*
    if (self = [super init])
    {
        m_pCallback = cAlert;
        NSArray* list = [configDict objectForKey:@"list"];
        NSArray* buttons = [configDict objectForKey:@"buttons"];
        NSString* title = [configDict valueForKey:@"title"];
        
        if(list==nil)
        {
            m_listArray = nil;
            NSString* msg = [configDict valueForKey:@"msg"];
            if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
            {
                UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
                for(NSUInteger i=0; i<[buttons count]; i++)
                {
                    [alertController addAction:[UIAlertAction actionWithTitle:[buttons objectAtIndex:i] style:((i==[buttons count]-1) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault) handler:nil]];
                }
                
            }
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:[buttons objectAtIndex:0] otherButtonTitles:nil];
            for(NSUInteger i=1; i<[buttons count]; i++)
            {
                [alertView addButtonWithTitle:[buttons objectAtIndex:i]];
            }
            [alertView show];
            [alertView release];
        }
        else{
            m_listArray = [NSArray arrayWithArray:list];
            [m_listArray retain];
            UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, [m_listArray count] * 40.0f) style:UITableViewStylePlain];
            tableView.dataSource = self;
            tableView.delegate = self;
            CustomAlertView* alertView = [[CustomAlertView alloc] initWithTitle:title content:tableView cancelButton:[buttons objectAtIndex:0] otherButtons:nil];
            alertView.delegate = self;
            [alertView show];
            [alertView release];
            [tableView release];
        }
    }
    */
    return nil;
}

- (void)dealloc
{
    /*
    if (m_listArray!=nil)
    {
        [m_listArray release];
        m_listArray = nil;
    }
    [super dealloc];
     */
}

@end

void NativeAlert::show()
{
    NSError* error = nil;
    NSData* configData = [NSData dataWithBytes:m_sConfig.data() length:m_sConfig.size()];
    NSDictionary* configDict = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingMutableLeaves error:&error];
    if(error==nil)
    {
        //this->retain();
        //[[LocalAlertDelegate alloc] initWithDictionary:configDict callback:this];
    }
}