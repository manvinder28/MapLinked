//
//  AsyncImageView.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 10.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    AsyncImageCropNone,
    AsyncImageCropLong,
} AsyncImageCrop;

@interface AsyncImageView : UIImageView <NSURLConnectionDelegate>

@property(nonatomic, strong) UIImage *defaultImage;
@property(nonatomic, strong) UIImage *maskImage;
@property(nonatomic, strong) NSURL *linkedUrl;
@property(nonatomic, readwrite) BOOL useLoadIndicator;

- (void)loadImageFromURL:(NSURL *)url;

- (void)remakeImage:(UIImage *)img;

+ (void)clearCache;

@property AsyncImageCrop typeCrop;

@end
