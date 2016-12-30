//
//  AppDelegate.m
//  ROKOMobiStickersDemo
//
//  Created by Katerina Vinogradnaya on 18.03.14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <ROKOLinkManagerDelegate>

@end;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.pushComponent = [[ROKOPush alloc]init];
	
	[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
	
	UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
	[center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
						  completionHandler:^(BOOL granted, NSError * _Nullable error) {
							  // Enable or disable features based on authorization.
						  }];
	
	[application registerForRemoteNotifications];
	
	self.linkManager = [[ROKOLinkManager alloc] init];
	self.linkManager.delegate = self;
	
	
	// Solution to receive notification when start app from APN
	NSDictionary *remoteNotificationInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
	if (remoteNotificationInfo) {
		[self application:application didReceiveRemoteNotification:remoteNotificationInfo];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushPageNotificationHandler:) name:kROKOPushPageNotification object:nil];
	
	return YES;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {

}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self.pushComponent registerWithAPNToken:deviceToken withCompletion:^(id responseObject, NSError *error) {
        
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[self.pushComponent handleNotification:userInfo];
}

- (void)handlePageNotification:(NSNotification *)notification {
	NSString *pageId = [[notification userInfo] objectForKey:kROKOPushPageIndexKey];
	
	UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
	if (![rootController isKindOfClass:[UINavigationController class]]) {
		__weak AppDelegate *weakSelf = self;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[weakSelf handlePageNotification:notification];
		});
		return;
	}
	UINavigationController *navigationController = (UINavigationController *)rootController;
	if ([navigationController.viewControllers count] < 1) {
		return;
	}
	
	UIViewController *controller = navigationController.childViewControllers[0];
	
	if (![controller isKindOfClass:[ViewController class]]) {
		return;
	}
	ViewController *firstController = (ViewController *)controller;
	[firstController switchToPageWithId:pageId];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
	[self.linkManager continueUserActivity:userActivity];
	
	return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	
	[self.linkManager handleDeepLink:url];
	
	return YES;
}

#pragma mark -
#pragma mark ROKOLinkManagerDelegate methods

- (void)linkManager:(ROKOLinkManager *)manager didOpenDeepLink:(ROKOLink *)link {
    if (link) {
        self.sharedLink = link;
    }
	if ([link.referralCode length] > 0) {
		self.sharedReferralCode = link.referralCode;
	}
	if ([link.promoCode length] > 0) {
		self.sharedPromoCode = link.promoCode;
	}
	if (link.shareChannel) {
		self.sharedLinkChannel = link.shareChannel;
	}
}

- (void)linkManager:(ROKOLinkManager *)manager didFailToOpenDeepLinkWithError:(NSError *)error {
	
}

- (void)pushPageNotificationHandler:(NSNotification *)notification {
	// Parse notification data
	NSString *pageInfo = [notification.userInfo description];
	
	// Show app page
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Page" message:pageInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

@end
