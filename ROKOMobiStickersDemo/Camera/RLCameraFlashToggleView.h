//
//  RLCameraFlashToggleView.h
//  ROKOStickers
//
//  Created by Katerina Vinogradnaya on 01.05.14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, RLFlashMode) {
	kRLFlashModeAuto = 0,
	kRLFlashModeOn,
	kRLFlashModeOff
};

@protocol RLCameraFlashToggleViewDelegate <NSObject>

- (void)turnFlashOn:(RLFlashMode)flashMode;

@end


@interface RLCameraFlashToggleView : UIView
@property (weak, nonatomic) id <RLCameraFlashToggleViewDelegate> delegate;
@property (assign, nonatomic) BOOL isExpanded;
@property (strong, nonatomic)IBOutletCollection(UIButton) NSArray * flashButtonsCollection;


- (IBAction)flashButtonPressed:(UIButton *)sender;
@end
