//
//  ImageCacheObject.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 10.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "ImageCacheObject.h"

@implementation ImageCacheObject

@synthesize size;
@synthesize timeStamp;
@synthesize image;

- (id)initWithSize:(NSUInteger)sz Image:(UIImage *)anImage {
    if (self = [super init]) {
        size = sz;
        timeStamp = [NSDate date];
        image = anImage;
    }
    return self;
}

- (void)resetTimeStamp {
    timeStamp = nil;
    timeStamp = [NSDate date];
}

@end