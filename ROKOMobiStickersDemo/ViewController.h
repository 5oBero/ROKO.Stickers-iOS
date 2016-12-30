//
//  ViewController.h
//  ROKOMobiStickersDemo
//
//  Created by Katerina Vinogradnaya on 6/20/14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ROKOMobi/ROKOMobi.h>

@interface ViewController : UIViewController <RLPhotoComposerDelegate>

- (void)reloadStickers;
- (void)switchToPageWithId:(NSString *)pageId;

@end
