//
//  AppDelegate.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define appDelegate ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)registerForPushNotifications;
- (void)scheduleLocalNotificationWithMessage:(NSString*)msg afterTimeInterval:(NSTimeInterval)delay notifierId:(NSString*)notifierId userInfo:(NSDictionary*)userInfo;
- (void)cancelLocalNotificationsWithId:(NSString*)notifierId;
- (void)resetLocalNotifications;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

