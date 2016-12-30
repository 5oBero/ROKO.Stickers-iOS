//
//  StickerPack.h
//  ROKOMobiStickersDemo
//
//  Created by Katerina Vinogradnaya on 6/21/14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StickerPack : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *packDescription;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) NSMutableArray *stickers;
@property (assign, nonatomic) NSInteger stickersNumber;
@property (assign, nonatomic) BOOL isUnlocked;
@property (assign, nonatomic) BOOL isPrivate;

- (instancetype)initWithName:(NSString *)name stickersNumber:(NSInteger)number;

@end
