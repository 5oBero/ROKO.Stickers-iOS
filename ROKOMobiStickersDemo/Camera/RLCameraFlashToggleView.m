//
//  RLCameraFlashToggleView.m
//  ROKOStickers
//
//  Created by Katerina Vinogradnaya on 01.05.14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import "RLCameraFlashToggleView.h"

@interface RLCameraFlashToggleView ()
@property (weak, nonatomic) IBOutlet UIImageView *flashImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flashButtonOnLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flashButtonAutoLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flashButtonOffLeadingConstraint;
@end

@implementation RLCameraFlashToggleView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		// Initialization code
	}

	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.isExpanded = NO;

	for (UIButton *button in self.flashButtonsCollection) {
		[self setTitleLetterSpacingForButton:button];
	}
}

- (void)setTitleLetterSpacingForButton:(UIButton *)button {
	NSAttributedString *string = button.currentAttributedTitle;

	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
	[attributedString addAttribute:NSKernAttributeName
	 value:@(2.0)
	 range:NSMakeRange(0, [string length])];

	[button setAttributedTitle:attributedString forState:UIControlStateNormal];
}

- (IBAction)flashButtonPressed:(UIButton *)sender {
	sender.userInteractionEnabled = NO;

	if (!self.isExpanded) {
		self.flashButtonOffLeadingConstraint.constant = 114.f;
		self.flashButtonOnLeadingConstraint.constant = 68.f;
		self.flashButtonAutoLeadingConstraint.constant = 21.f;
	} else {
		self.flashButtonOffLeadingConstraint.constant = 16.f;
		self.flashButtonOnLeadingConstraint.constant = 16.f;
		self.flashButtonAutoLeadingConstraint.constant = 21.f;
	}

	NSString *flashImageName = nil;

	if (self.isExpanded && (sender.tag == kRLFlashModeOff)) {
		flashImageName = @"flash_white";
	} else {
		flashImageName = @"flash";
	}

//	UIImage *flashImage = [UIImage imageWithContentsOfFile:
//	                       [[NSFileManager frameworkBundle] pathForResource:flashImageName
//	                        ofType:@"png"]];
    UIImage *flashImage = [UIImage imageNamed:flashImageName];


	[UIView animateWithDuration:0.3 animations:^{
	    [self.flashButtonsCollection enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
	        button.alpha = (sender == button) ? 1 : self.isExpanded ? 0 : 1;
		}];
	    self.flashImageView.image = flashImage;
	    [self layoutIfNeeded];
	} completion:^(BOOL finished) {
	    sender.userInteractionEnabled = YES;

	    if (self.isExpanded) {
	        if (self.delegate && [self.delegate respondsToSelector:@selector(turnFlashOn:)]) {
	            [self.delegate turnFlashOn:sender.tag];
			}
		}

	    self.isExpanded = !self.isExpanded;
	}];
}

@end
