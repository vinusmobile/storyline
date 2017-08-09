//
//  AppDelegate.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"
#import "RMStore.h"
#import "ResourceManager.h"
#import "Amplitude.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Appirater.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "RMStoreAppReceiptVerificator.h"
#import <OneSignal/OneSignal.h>

#define kLocalNotificatKey @"localTimer"


@interface AppDelegate ()

@property (nonatomic, strong) RMStoreAppReceiptVerificator *receiptVerifier;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Appirater setAppId:@"1174529077"];
    [Appirater setDaysUntilPrompt:0];
    [Appirater setUsesUntilPrompt:0];
    [Appirater setSignificantEventsUntilPrompt:1];
    [Appirater setTimeBeforeReminding:2];
    
    [OneSignal initWithLaunchOptions:launchOptions appId:@"b5669e53-75e4-42bd-b329-4b901d2ded5e" handleNotificationReceived:^(OSNotification *notification) {
        
    } handleNotificationAction:^(OSNotificationOpenedResult *result) {
        
    } settings:@{kOSSettingsKeyAutoPrompt:@NO}];

#ifdef DEBUG
//    [Appirater setDebug:YES];
#endif
    [Appirater appLaunched:YES];
    
    // Override point for customization after application launch.
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Stories"];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelError];
    
    [Fabric with:@[[Crashlytics class]]];

    _receiptVerifier = [[RMStoreAppReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = _receiptVerifier;

    _receiptVerifier.bundleIdentifier = @"com.pz.story";
    
    [[Amplitude instance] initializeApiKey:@"f8b8882bf28215a6897d7f7d97f35514"];
    
    [[DataManager sharedInstance] requestIAPs];
    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    NSLog(@"Download Directory: %@", [ResourceManager downloadDirectory]);
    return YES;
}
    
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark Local notifications
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)registerForPushNotifications {
    [OneSignal registerForPushNotifications];
//    // ask user to allow push notification
//    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


// if user info contains an id it can be used to retrieve the notificaiton to cancel it later
- (void)scheduleLocalNotificationWithMessage:(NSString*)msg afterTimeInterval:(NSTimeInterval)delay notifierId:(NSString*)notifierId userInfo:(NSDictionary*)userInfo {
    UILocalNotification *n = [[UILocalNotification alloc] init];
    NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithObject:kLocalNotificatKey forKey:@"class"];
    if (msg) {
        [newUserInfo setObject:msg forKey:@"alertMessage"];
    }
    if (notifierId) {
        [newUserInfo setObject:notifierId forKey:@"notifierId"];
    }
    
    if (userInfo) {
        [newUserInfo addEntriesFromDictionary:userInfo];
    }
    
    n.alertBody = msg;
    //    n.soundName = @"sfx_monsters_push_notification.caf";
    n.fireDate = [NSDate dateWithTimeIntervalSinceNow:delay];
    n.userInfo = newUserInfo;
    
    [self cancelLocalNotificationsWithId:notifierId];
    [[UIApplication sharedApplication] scheduleLocalNotification:n];
}

- (void)cancelLocalNotificationsWithId:(NSString*)notifierId {
    NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSArray *filteredArray = [notificationArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userInfo.notifierId == %@", notifierId]];
    [filteredArray enumerateObjectsUsingBlock:^(UILocalNotification* obj, NSUInteger idx, BOOL *stop) {
        [[UIApplication sharedApplication] cancelLocalNotification:obj];
    }];
}

- (void)resetLocalNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}



#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"storyline"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
