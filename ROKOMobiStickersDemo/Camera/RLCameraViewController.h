//
//  RLCameraViewController.h
//  AugmentedRealityFramework
//
//  Created by Katerina Vinogradnaya on 27.02.14.
//  Copyright (c) 2014 RokoLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ROKOMobi/RLPhotoComposerController.h>
#import "RLComposerWorkflowController.h"

@interface RLCameraViewController : RLPhotoComposerController

+ (instancetype)buildCameraControllerWithWorkflow:(RLComposerWorkflowType)workflow;

@end
