//
//  AppDelegate.h
//  ROKOMobiStickersDemo
//
//  Created by Katerina Vinogradnaya on 18.03.14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ROKOMobi/ROKOMobi.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString *sharedReferralCode;
@property (nonatomic, copy) NSString *sharedPromoCode;
@property (nonatomic, copy) NSString *sharedLinkChannel;
@property (nonatomic, strong) ROKOLink *sharedLink;

@property (nonatomic, strong) ROKOPush *pushComponent;
@property (nonatomic, strong) ROKOLinkManager *linkManager;

@end
