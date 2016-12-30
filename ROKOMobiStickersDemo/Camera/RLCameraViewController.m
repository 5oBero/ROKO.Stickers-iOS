//
//  RLCameraViewController.m
//  AugmentedRealityFramework
//
//  Created by Katerina Vinogradnaya on 27.02.14.
//  Copyright (c) 2014 RokoLabs. All rights reserved.
//

#import "RLCameraViewController.h"
#import "RLImageCaptureViewController.h"
#import <ROKOMobi/ROKOMobi.h>


@interface RLCameraViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, RLImageCaptureViewControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (assign, nonatomic) RLComposerWorkflowType workflow;

@end

@implementation RLCameraViewController

#pragma mark - Initialization Methods

+ (instancetype)buildCameraControllerWithWorkflow:(RLComposerWorkflowType)workflow {
	RLCameraViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"cameraController"];
	controller.workflow = workflow;
	return controller;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIViewController *childViewController = nil;
	
	if (self.workflow == kRLComposerWorkflowTypeCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		RLImageCaptureViewController *imageCapture = [RLImageCaptureViewController buildImageCaptureController];
		imageCapture.delegate = self;
		childViewController = imageCapture;
	} else {
		self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		childViewController = self.imagePicker;
	}
	
	childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:childViewController.view];
	[self addChildViewController:childViewController];
	[childViewController didMoveToParentViewController:self];
	
	childViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
	if ([self.navigationController isKindOfClass:[RLComposerWorkflowController class]]) {
		RLComposerWorkflowController *workflowController = (RLComposerWorkflowController *)self.navigationController;
		if ([workflowController.workflowDelegate respondsToSelector:@selector(composerWorkflow:didOpenImagePicker:)]) {
			[workflowController.workflowDelegate composerWorkflow:workflowController didOpenImagePicker:self];
		}
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
	if (self.workflow == kRLComposerWorkflowTypeCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		return YES;
	}
	
	return NO;
}

- (BOOL)shouldAutorotate {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	} else {
		return NO;
	}
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}

#pragma mark- image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self presentStickersViewControllerWithPhoto:photo];
	if ([self.navigationController isKindOfClass:[RLComposerWorkflowController class]]) {
		RLComposerWorkflowController *workflowController = (RLComposerWorkflowController *)self.navigationController;
		if ([workflowController.workflowDelegate respondsToSelector:@selector(composerWorkflow:didSelectImage:)]) {
			[workflowController.workflowDelegate composerWorkflow:workflowController didSelectImage:photo];
		}
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:^{
	    if (self.delegate && [self.delegate respondsToSelector:@selector(composerDidCancel:)]) {
	        [self.delegate composerDidCancel:self];
		}
	}];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	UINavigationBar *navigationBar = navigationController.navigationBar;
	navigationBar.hidden = NO;
	
	UINavigationItem *navigationItem = navigationBar.topItem;
	navigationItem.backBarButtonItem = backButton;
	
	NSString *title = viewController.title;
	
	UILabel *titleView = (UILabel *)viewController.navigationItem.titleView;
	
	if (!titleView) {
		titleView = [[UILabel alloc] initWithFrame:CGRectZero];
		titleView.backgroundColor = [UIColor clearColor];
	}
	
	titleView.font = [UIFont systemFontOfSize:18.0];
//	titleView.textColor = [[RLSettingsManager sharedManager] frameworkGrayColor];
	viewController.navigationItem.titleView = titleView;
	titleView.text = title;
	[titleView sizeToFit];
}

#pragma mark - Image Capture Controller Delegate

- (void)imageCaptureController:(RLImageCaptureViewController *)controller didFinishWithPhoto:(UIImage *)photo {
	[self presentStickersViewControllerWithPhoto:photo];
}

- (void)imageCaptureControllerDidCancel:(RLImageCaptureViewController *)controller {
	[controller dismissViewControllerAnimated:YES completion:nil];
	[self.presentingViewController dismissViewControllerAnimated:YES completion:^{
	    if (self.delegate && [self.delegate respondsToSelector:@selector(composerDidCancel:)]) {
	        [self.delegate composerDidCancel:self];
		}
	}];
}

#pragma mark - Private Methods

- (void)presentStickersViewControllerWithPhoto:(UIImage *)photo {
	RLPhotoStickersViewController *controller = [RLPhotoStickersViewController buildPhotoStickersController];
	
	controller.photo = photo;
	controller.photoType = self.photoType;
	controller.delegate = self.delegate;
	controller.dataSource = self.dataSource;
	controller.enablePhotoSharing = self.enablePhotoSharing;
	
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - properties

- (UIImagePickerController *)imagePicker {
	if (nil != _imagePicker) {
		return _imagePicker;
	}
	
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	_imagePicker.allowsEditing = NO;
	_imagePicker.view.frame = self.view.bounds;
	
	return _imagePicker;
}

@end
