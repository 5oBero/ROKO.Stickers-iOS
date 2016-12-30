//
//  RLImageCaptureViewController.m
//  ROKOStickers
//
//  Created by Katerina Vinogradnaya on 01.05.14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "RLImageCaptureViewController.h"
#import "RLCameraFlashToggleView.h"

@interface RLImageCaptureViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, RLCameraFlashToggleViewDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (assign, nonatomic) AVCaptureVideoOrientation pictureOrientation;

@property (weak, nonatomic) IBOutlet RLCameraFlashToggleView *flashButtonsView;
@property (weak, nonatomic) IBOutlet UIView *cameraPreview;
@property (assign, nonatomic) RLFlashMode selectedFlashMode;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;

- (IBAction)imageCaptureButtonPressed:(UIButton *)sender;
- (IBAction)switchCameraButtonPressed:(id)sender;
- (IBAction)cameraRollButtonPressed:(UIButton *)sender;
- (IBAction)cancelButtonPressed:(UIButton *)sender;

@end

@implementation RLImageCaptureViewController


+ (instancetype)buildImageCaptureController {
	[RLCameraFlashToggleView class];

	RLImageCaptureViewController *imageCaptureController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"imageCaptureController"];
	return imageCaptureController;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.selectedFlashMode = kRLFlashModeAuto;
    [_flashButtonsView setHidden: ![[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] hasFlash] ];
	self.flashButtonsView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self addCapturePreviewLayer];
		[self.captureSession startRunning];
	});
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		_capturePreviewLayer.frame = self.cameraPreview.bounds;
		
		[self fixPreviewOrientation];
	} completion:nil];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}

#pragma mark - Properties

- (AVCaptureSession *)captureSession {
	if (nil != _captureSession) {
		return _captureSession;
	}

	_captureSession = [[AVCaptureSession alloc] init];
	_captureSession.sessionPreset = AVCaptureSessionPresetPhoto;

	AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
	self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];

	if ([_captureSession canAddInput:self.deviceInput]) {
		[_captureSession addInput:self.deviceInput];
	} else {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sharing" message:@"Camera access is restricted for the app. Please allow to use camera in device settings" preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
		[alert addAction:cancel];
		
		UIAlertAction *prefs = [UIAlertAction actionWithTitle:@"Open settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
		}];
		[alert addAction:prefs];
		
		[self presentViewController:alert animated:YES completion:nil];
	}

	self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	[self.stillImageOutput setOutputSettings:@{AVVideoCodecJPEG: AVVideoCodecKey}];

	if ([_captureSession canAddOutput:self.stillImageOutput]) {
		[_captureSession addOutput:self.stillImageOutput];
	}

	return _captureSession;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) {
			return (AVCaptureDevice *)device;
		}
	}

	return nil;
}

- (void)addCapturePreviewLayer {
	if (!_capturePreviewLayer) {
		_capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
		[self.cameraPreview.layer insertSublayer:_capturePreviewLayer atIndex:0];
	}

	CGRect frame = self.view.bounds;
	[_capturePreviewLayer setFrame:frame];

	[_capturePreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];

	[self fixPreviewOrientation];
}

- (void)fixPreviewOrientation {
	AVCaptureConnection *previewLayerConnection = _capturePreviewLayer.connection;
	
	if ([previewLayerConnection isVideoOrientationSupported]) {
		UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
		[previewLayerConnection setVideoOrientation:(AVCaptureVideoOrientation)statusBarOrientation];
	}
}

#pragma mark - Buttons Interaction

- (IBAction)imageCaptureButtonPressed:(UIButton *)sender {
	sender.userInteractionEnabled = NO;

	AVCaptureConnection *stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.stillImageOutput connections]];

	if ([stillImageConnection isVideoOrientationSupported]) {
		UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
		[stillImageConnection setVideoOrientation:(AVCaptureVideoOrientation)statusBarOrientation];
	}

	if (!stillImageConnection) {
		sender.userInteractionEnabled = NO;
		return;
	}

	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
	 completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
	{
	    if (imageDataSampleBuffer != NULL) {
	        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
	        UIImage *capture = [[UIImage alloc] initWithData:imageData];

			AVCaptureDevicePosition position = [[self.deviceInput device] position];
			if (position == AVCaptureDevicePositionFront) {
	            capture = [UIImage imageWithCGImage:capture.CGImage scale:capture.scale orientation:UIImageOrientationLeftMirrored];
			}

	        capture = [self fixOrientationForImage:capture position:position];

	        if (self.delegate && [self.delegate respondsToSelector:@selector(imageCaptureController:didFinishWithPhoto:)]) {
	            _imageSourceType = UIImagePickerControllerSourceTypeCamera;
	            [self.delegate imageCaptureController:self didFinishWithPhoto:capture];
			}
		}

	    sender.userInteractionEnabled = YES;
	}];
}

- (UIImage *)fixOrientationForImage:(UIImage *)image position:(AVCaptureDevicePosition)position {
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	
	switch (deviceOrientation) {
		case UIDeviceOrientationLandscapeLeft: {
			UIImageOrientation orientation = (position == AVCaptureDevicePositionFront) ? UIImageOrientationDown : UIImageOrientationUp;
			return [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:orientation];
		}
			
			break;
		case UIDeviceOrientationLandscapeRight: {
			UIImageOrientation orientation = (position == AVCaptureDevicePositionFront) ? UIImageOrientationUp : UIImageOrientationDown;
			return [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:orientation];
		}
		case UIDeviceOrientationPortraitUpsideDown:
			return [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeft];
		default:
			return image;
			break;
	}
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
	for (AVCaptureConnection *connection in connections) {
		for (AVCaptureInputPort *port in[connection inputPorts]) {
			if ([[port mediaType] isEqual:mediaType]) {
				return connection;
			}
		}
	}

	return nil;
}

- (IBAction)switchCameraButtonPressed:(id)sender {
	if ([self cameraCount] > 1) {
		NSError *error = nil;
		AVCaptureDevice *device = nil;
		AVCaptureDevicePosition position = [[self.deviceInput device] position];

		CGFloat alpha = 1.0;
		BOOL flashButtonsEnabled = YES;
		BOOL collapseFlashButtons = NO;

		if (position == AVCaptureDevicePositionBack) {
			device = [self cameraWithPosition:AVCaptureDevicePositionFront];
			alpha = 0.f;
			flashButtonsEnabled = NO;

			if (self.flashButtonsView.isExpanded) {
				collapseFlashButtons = YES;
			}
		} else if (position == AVCaptureDevicePositionFront) {
			device = [self cameraWithPosition:AVCaptureDevicePositionBack];
		}

		AVCaptureDeviceInput *newDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];

		if (newDeviceInput != nil) {
			[self.captureSession beginConfiguration];
			[self.captureSession removeInput:self.deviceInput];
			self.capturePreviewLayer.connection.automaticallyAdjustsVideoMirroring = YES;

			if (collapseFlashButtons) {
				[self.flashButtonsView flashButtonPressed:self.flashButtonsView.flashButtonsCollection[kRLFlashModeAuto]];
			}

			[self.captureSession commitConfiguration];

			[UIView transitionWithView:self.cameraPreview duration:0.5 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft animations:^{
			    self.cameraPreview.alpha = 0.3;
			} completion:^(BOOL finished) {
			    [self.captureSession beginConfiguration];

			    if ([self.captureSession canAddInput:newDeviceInput]) {
			        [self.captureSession addInput:newDeviceInput];
			        self.deviceInput = newDeviceInput;
				} else {
			        [self.captureSession addInput:self.deviceInput];
				}

			    self.cameraPreview.alpha = 1.0;
			    [self dimFlashButtons:alpha enabled:flashButtonsEnabled];
			    [self.captureSession commitConfiguration];
			}];
		}
	}
}

- (NSUInteger)cameraCount {
	return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (void)dimFlashButtons:(CGFloat)alpha enabled:(BOOL)enabled;
{
	self.flashButtonsView.alpha = alpha;

	if (enabled) {
		[self turnFlashOn:self.selectedFlashMode];
	}
}

- (IBAction)cameraRollButtonPressed:(UIButton *)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.allowsEditing = NO;
	imagePicker.view.frame = self.view.bounds;

	[self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
	if (self.delegate && [self.delegate respondsToSelector:@selector(imageCaptureControllerDidCancel:)]) {
		[self.delegate imageCaptureControllerDidCancel:self];
	}
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

	if (self.delegate && [self.delegate respondsToSelector:@selector(imageCaptureController:didFinishWithPhoto:)]) {
		_imageSourceType = picker.sourceType;
		[self.delegate imageCaptureController:self didFinishWithPhoto:image];
	}

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Flash Buttons View Delegate

- (void)turnFlashOn:(RLFlashMode)flashMode {
	self.selectedFlashMode = flashMode;

	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");

	if (captureDeviceClass != nil) {
		AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

		if ([device hasTorch] && [device hasFlash]) {

			[device lockForConfiguration:nil];

			switch (flashMode) {
			case kRLFlashModeAuto: {
				[device setTorchMode:AVCaptureTorchModeAuto];
				[device setFlashMode:AVCaptureFlashModeAuto];
				break;
			}
			case kRLFlashModeOn: {
				[device setTorchMode:AVCaptureTorchModeOn];
				[device setFlashMode:AVCaptureFlashModeOn];
				break;
			}
			case kRLFlashModeOff: {
				[device setTorchMode:AVCaptureTorchModeOff];
				[device setFlashMode:AVCaptureFlashModeOff];
				break;
			}
			}

			[device unlockForConfiguration];
		}
	}
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
	viewController.navigationItem.titleView = titleView;
	titleView.text = title;
	[titleView sizeToFit];
}

@end
