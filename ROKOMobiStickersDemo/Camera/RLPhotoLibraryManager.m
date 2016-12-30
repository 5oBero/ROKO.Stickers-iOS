//
//  RLPhotoLibraryManager.m
//  ROKOStickers
//
//  Created by Katerina Vinogradnaya on 23.04.14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import "RLPhotoLibraryManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface RLPhotoLibraryManager ()
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (copy, nonatomic) NSString *photoAlbumName;
@end

@implementation RLPhotoLibraryManager

+ (instancetype)sharedManager {
	static RLPhotoLibraryManager *sPhotoLibraryManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken,
		^{
		sPhotoLibraryManager = [RLPhotoLibraryManager new];
	});

	return sPhotoLibraryManager;
}

- (void)savePhoto:(UIImage *)photo metaData:(NSMutableDictionary *)metaData album:(NSString *)album completion:(void (^)(NSError *))completion {
//    [self.assetsLibrary writeImageToSavedPhotosAlbum:photo.CGImage
//                                         orientation:(ALAssetOrientation)photo.imageOrientation
//                                     completionBlock:^(NSURL *assetURL, NSError *error) {
//                                         if (!error) {
//                                             NSString *albumName = (nil != album)? album : self.photoAlbumName;
//                                             [self savePhotoWithURL:assetURL toAlbum:albumName];
//                                         }
//                                         if (completion) {
//                                             completion (error);
//                                         }
//                                     }];

	[metaData setObject:@((ALAssetOrientation)photo.imageOrientation) forKey:(NSString *)kCGImagePropertyOrientation];

	[self.assetsLibrary writeImageToSavedPhotosAlbum:photo.CGImage metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
	    if (!error) {
	        NSString *albumName = (nil != album) ? album : self.photoAlbumName;
	        [self savePhotoWithURL:assetURL toAlbum:albumName];
		}

	    if (completion) {
	        completion (error);
		}
	}];
}

- (void)savePhotoWithURL:(NSURL *)photoURL toAlbum:(NSString *)albumName {
	__block BOOL albumWasFound = NO;

	[self.assetsLibrary assetForURL:photoURL resultBlock:^(ALAsset *asset) {
	    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
	        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
	            [group addAsset:asset];
	            albumWasFound = YES;
	            *stop = YES;
			} else if (!group && albumWasFound == NO) {
	            [self.assetsLibrary addAssetsGroupAlbumWithName:albumName
	             resultBlock:^(ALAssetsGroup *addedGroup) {
	                [addedGroup addAsset:asset];
				}
	             failureBlock:nil];
	            *stop = YES;
			}
		} failureBlock:nil];
	} failureBlock:nil];
}

#pragma mark - Properties

- (ALAssetsLibrary *)assetsLibrary {
	if (nil != _assetsLibrary) {
		return _assetsLibrary;
	}

	_assetsLibrary = [ALAssetsLibrary new];
	return _assetsLibrary;
}

- (NSString *)photoAlbumName {
	if (nil != _photoAlbumName) {
		return _photoAlbumName;
	}

	_photoAlbumName = @"ROKO Stickers";
	return _photoAlbumName;
}

@end
