//
//  ViewController.m
//  ROKOMobiStickersDemo
//
//  Created by Katerina Vinogradnaya on 6/20/14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "RLComposerWorkflowController.h"
#import "RLPhotoLibraryManager.h"

NSString *const kROKOEmbededStickersSchemeName = @"EmbededStickersScheme";
NSString *const kROKOStickersShareContentTypeKey = @"_ROKO.ImageWithStickers";


@interface ViewController () <RLComposerWorkflowControllerDelegate> {
	ROKOStickersCustomizer *_stickersCustomizer;
	ROKOStickersScheme *_stickersScheme;
	ROKOPortalStickersDataSource *_dataSource;
	NSTimer *_timer;
	__weak RLComposerWorkflowController *_workflowController;
	__weak RLPhotoComposerController *_activeStickerComposer;
	BOOL _pickerIsActive;
}

- (IBAction)takePhotoButtonPressed:(UIButton *)sender;
- (IBAction)choosePhotoButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_stickersCustomizer =  [[ROKOStickersCustomizer alloc]init];
	_dataSource = [[ROKOPortalStickersDataSource alloc]initWithManager:nil];
	// Do any additional setup after loading the view.
	_timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerHandler:) userInfo:nil repeats:NO];
	[_timer fire];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStickers) name:UIApplicationDidBecomeActiveNotification object:nil];
	
	self.versionLabel.text = [@"v." stringByAppendingString:[self appVersion]];
}

- (void)dealloc {
	[_timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self loadDefaultScheme];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)loadStickersForController:(RLComposerWorkflowController *)controller {
	__weak RLPhotoComposerController *composer = controller.composer;
	[_dataSource reloadStickersWithCompletionBlock:^(id responseObject, NSError *error) {
		[composer reloadData];
	}];
}

- (void)reloadStickers {
	[self loadStickersForController:_workflowController];
}

- (void)switchToPageWithId:(NSString *)pageId {
	if ([self presentedViewController]) {
		[self dismissViewControllerAnimated:YES completion:^{
			[self switchToPageWithId:pageId];
		}];
	} else {
		[self openPageWithId:pageId];
	}
}

- (void)openPageWithId:(NSString *)pageId {
	if ([pageId isEqualToString:@"page1"]) {
		[self takePhotoButtonPressed:nil];
		return;
	}
	
	if ([pageId isEqualToString:@"page2"]) {
		[self choosePhotoButtonPressed:nil];
		return;
	}
}

#pragma mark - Button Interaction

- (IBAction)takePhotoButtonPressed:(UIButton *)sender {
	RLComposerWorkflowController *workflowController = [RLComposerWorkflowController buildComposerWorkflowWithType:kRLComposerWorkflowTypeCamera];

	if (workflowController) {
		RLPhotoComposerController *photoComposer = workflowController.composer;
		photoComposer.dataSource = _dataSource;
		photoComposer.delegate = self;
		photoComposer.scheme = _stickersScheme;
		photoComposer.enablePhotoSharing = YES;
		photoComposer.photoType = ROKOPhotoTypeCamera;
		workflowController.workflowDelegate = self;
	
		[self loadStickersForController:workflowController];
		[self presentViewController:workflowController animated:YES completion:nil];
	}
	_workflowController = workflowController;
}

- (IBAction)choosePhotoButtonPressed:(UIButton *)sender {
	RLComposerWorkflowController *workflowController = [RLComposerWorkflowController buildComposerWorkflowWithType:kRLComposerWorkflowTypePhotoPicker];

	if (workflowController) {
		RLPhotoComposerController *photoComposer = workflowController.composer;
		photoComposer.delegate = self;
		photoComposer.dataSource = _dataSource;
		photoComposer.scheme = _stickersScheme;
		photoComposer.enablePhotoSharing = YES;
		photoComposer.photoType = ROKOPhotoTypePhotoPicker;
		workflowController.workflowDelegate = self;
		
		[self loadStickersForController:workflowController];
		[self presentViewController:workflowController animated:YES completion:nil];
	}
	_workflowController = workflowController;
}

#pragma mark - RLCameraViewController Delegate

- (void)composer:(RLPhotoComposerController *)composer didFinishWithPhoto:(UIImage *)photo {
	return;
}

- (void)composerDidCancel:(RLPhotoComposerController *)composer {
	return;
}

- (void)composer:(RLPhotoComposerController *)composer willAppearAnimated:(BOOL)animated {
	if (_stickersScheme) {
		composer.scheme = _stickersScheme;
	}
	
	if (composer != _activeStickerComposer) {
		// first open
		_activeStickerComposer = composer;
	} else {
		[ROKOLogger addEvent:@"Back to Edit" withParameters:nil];
	}
}

- (void)composer:(RLPhotoComposerController *)composer didPressShareButtonForImage:(UIImage *)image {
	
	ROKOShareViewController *controller = [ROKOShareViewController buildControllerWithContentId:[[NSUUID UUID]UUIDString]];

	if (nil != controller) {
		controller.shareManager.image = image;
		NSString *message = @"I made this for you on the ROKO Stickers app!";
		[controller setDisplayMessage:message];
		controller.shareManager.contentId = [composer.photoId UUIDString];
		controller.shareManager.contentType = kROKOStickersShareContentTypeKey;
		composer.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
		[composer.navigationController presentViewController:controller animated:YES completion:nil];
		
		[ROKOLogger addEvent:@"Share Button Selected" withParameters:nil];
	}
}

- (void)composer:(RLPhotoComposerController *)composer didAddSticker:(RLStickerInfo *)stickerInfo {
   
}
- (void)composer:(RLPhotoComposerController *)composer didSwitchToStickerPackAtIndex:(NSInteger)packIndex{
    
}

- (void)composer:(RLPhotoComposerController *)composer didRemoveSticker:(RLStickerInfo *)stickerInfo {

}

- (void)composer:(RLPhotoComposerController *)composer shoudlSaveImage:(UIImage *)image toAlbumWithName:(NSString *)albumName {
	NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
	[[RLPhotoLibraryManager sharedManager] savePhoto:image metaData:metaData album:albumName completion:nil];
}

- (NSString *)appVersion {
	NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
	return [infoDict objectForKey:@"CFBundleShortVersionString"];
}

#pragma mark -
#pragma mark RLComposerWorkflowControllerDelegate methods

- (void)composerWorkflow:(RLComposerWorkflowController *)workflowController didOpenImagePicker:(UIViewController *)picker {
	if (_pickerIsActive) {
		// first open of camera/gallery
		[self informAboutBackToCamera:workflowController];
		return;
	}
	
	_pickerIsActive = YES;
	[self informAboutFirstOpen:workflowController];
}

- (void)composerWorkflow:(RLComposerWorkflowController *)workflowController didSelectImage:(UIImage *)image {
	NSString *eventName = nil;
	switch (workflowController.type) {
		case kRLComposerWorkflowTypePhotoPicker:
			eventName = @"Photo Selected";
			break;
		default:
			return;
	}
	[ROKOLogger addEvent:eventName withParameters:nil];
}

- (void)composerWorkflow:(RLComposerWorkflowController *)workflowController didCloseImagePicker:(UIViewController *)picker {
	_pickerIsActive = NO;
}

- (void)informAboutFirstOpen:(RLComposerWorkflowController *)workflowController {
	NSString *eventName = nil;
	switch (workflowController.type) {
		case kRLComposerWorkflowTypeCamera:
			eventName = @"Take Photo";
			break;
		case kRLComposerWorkflowTypePhotoPicker:
			eventName = @"Choose Photo";
			break;
		default:
			// Some wrong workflow
			return;
	}
	[ROKOLogger addEvent:eventName withParameters:nil];
}

- (void)informAboutBackToCamera:(RLComposerWorkflowController *)workflowController {
	NSString *eventName = nil;
	switch (workflowController.type) {
		case kRLComposerWorkflowTypeCamera:
			eventName = @"Back to Camera";
			break;
		case kRLComposerWorkflowTypePhotoPicker:
			eventName = @"Back to Album";
			break;
		default:
			// Some wrong workflow
			return;
	}
	[ROKOLogger addEvent:eventName withParameters:nil];
}

#pragma mark -
#pragma mark Periodicaly loading

- (void)loadDefaultScheme {
	[_stickersCustomizer loadSchemeWithCompletionBlock:^(ROKOStickersScheme *scheme, NSError *error) {
		if (!error) {
            if (!scheme.configurationViaPortal) {
                NSURL* urlForEmbededScheme = [[NSBundle mainBundle] URLForResource:kROKOEmbededStickersSchemeName withExtension:@""];
                _stickersScheme = (ROKOStickersScheme*)[_stickersCustomizer savedSchemeWithURL:urlForEmbededScheme];

            }
            else {
                _stickersScheme = scheme;
            }
		}
	}];
    
}

- (void)timerHandler:(NSTimer *)timer {
	[self loadDefaultScheme];
}

@end
