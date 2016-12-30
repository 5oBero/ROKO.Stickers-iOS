//
//  StickerPack.m
//  ROKOMobiStickersDemo
//
//  Created by Katerina Vinogradnaya on 6/21/14.
//  Copyright (c) 2014 ROKOLabs. All rights reserved.
//

#import "StickerPack.h"

@implementation StickerPack

- (instancetype)initWithName:(NSString *)name stickersNumber:(NSInteger)number
{
    self = [super init];
    
    if (self) {
        self.name = name;
        self.stickersNumber = number;
        self.stickers = [NSMutableArray new];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithName:nil stickersNumber:0];
}

- (BOOL)isUnlocked
{
    BOOL unlocked = [[NSUserDefaults standardUserDefaults] boolForKey:self.name];
    return unlocked;
}

- (void)setIsUnlocked:(BOOL)isUnlocked
{
    [[NSUserDefaults standardUserDefaults] setBool:isUnlocked forKey:self.name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
