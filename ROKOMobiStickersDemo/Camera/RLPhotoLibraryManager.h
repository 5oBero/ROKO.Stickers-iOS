//
//  RLPhotoLibraryManager.h
//  ROKOStickers
//
//  Created by Katerina Vinogradnaya on 23.04.14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RLPhotoLibraryManager : NSObject
+ (instancetype)sharedManager;
- (void)savePhoto:(UIImage *)photo metaData:(NSMutableDictionary *)metaData album:(NSString *)album completion:(void (^)(NSError *error))completion;
@end
