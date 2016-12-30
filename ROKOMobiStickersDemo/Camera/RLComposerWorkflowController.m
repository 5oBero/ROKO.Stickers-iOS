//
//  RLComposerWorkflowController.m
//  ROKOStickers
//
//  Created by Alexey Golovenkov on 08.03.15.
//  Copyright (c) 2015 ROKOLabs. All rights reserved.
//

//#import "RLCMSDataSource.h"
#import "RLCameraViewController.h"
#import "RLComposerWorkflowController.h"
#import <ROKOMobi/RLImagesCache.h>
#import <ROKOMobi/RLPhotoComposerController.h>
#import <ROKOMobi/RLPhotoStickersViewController.h>

@interface RLComposerWorkflowController ()

@end

@implementation RLComposerWorkflowController

+ (instancetype)buildComposerWorkflowWithType:(RLComposerWorkflowType)type {

	RLPhotoComposerController *controller = nil;

//	if (type == kRLComposerWorkflowTypeStickersSelector) {
//		controller = [RLPhotoStickersViewController buildPhotoStickersController];
//	} else {
//		controller = [RLCameraViewController buildCameraControllerWithWorkflow:type];
//	}
    controller = [RLCameraViewController buildCameraControllerWithWorkflow:type];

	RLComposerWorkflowController *workflowController = [[RLComposerWorkflowController alloc] initWithRootViewController:controller];
	[controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];

	if ([workflowController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
		workflowController.interactivePopGestureRecognizer.enabled = NO;
	}
	
	workflowController->_type = type;
	
	return workflowController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		// Custom initialization
	}

	return self;
}

- (void)dealloc {
	if ([self.workflowDelegate respondsToSelector:@selector(composerWorkflow:didCloseImagePicker:)]) {
		[self.workflowDelegate composerWorkflow:self didCloseImagePicker:[self.viewControllers firstObject]];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	[RLImagesCache clearCache];
}

- (BOOL)shouldAutorotate {
	return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (RLPhotoComposerController *)composer {
	return (RLPhotoComposerController *)[self topViewController];
}

@end
