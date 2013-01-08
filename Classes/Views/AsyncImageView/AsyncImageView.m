//
//  AsyncImageView.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 10.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "AsyncImageView.h"
#import "ImageCacheObject.h"
#import "ImageCache.h"

@interface AsyncImageView ()

@property(nonatomic, strong) UIImage *cachedImage;
@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, strong) NSString *urlString; // key for image cache dictionary
@property(nonatomic, strong) UIActivityIndicatorView *loadActivityIndicator;

@end

static ImageCache *imageCache = nil;

@implementation AsyncImageView


+ (void)clearCache {
    [imageCache clearCache];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.loadActivityIndicator setFrame:frame];
}

- (void)loadImageFromURL:(NSURL *)url {
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.data != nil) {
        self.data = nil;
    }

    if (imageCache == nil) {// lazily create image cache
        imageCache = [[ImageCache alloc] initWithMaxSize:2 * 1024 * 1024];  // 2 MB Image cache
    }

    self.urlString = [[url absoluteString] copy];


    // check cashed
    self.cachedImage = [imageCache imageForKey:self.urlString];
    if (self.cachedImage != nil) {
        [self remakeImage:self.cachedImage];
        return;
    }

    // add temp pic
    self.image = self.defaultImage;

    // init activity indicator
    if (self.useLoadIndicator) {
        CGRect activityFrame = self.frame;
        activityFrame.origin = CGPointZero;
        self.loadActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:activityFrame];
        self.loadActivityIndicator.hidesWhenStopped = YES;
        self.loadActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:self.loadActivityIndicator];
        [self.loadActivityIndicator startAnimating];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData {
    if (self.data == nil) {
        self.data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [self.data appendData:incrementalData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.loadActivityIndicator stopAnimating];
    self.loadActivityIndicator = nil;

    self.data = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    self.connection = nil;

    // get image
    UIImage *imageS = [UIImage imageWithData:self.data];

    [imageCache insertImage:imageS withSize:[self.data length] forKey:self.urlString];

    [self remakeImage:imageS];

    [self.loadActivityIndicator stopAnimating];
    self.loadActivityIndicator = nil;

    self.data = nil;
}

- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {

    CGImageRef maskRef = maskImage.CGImage;

    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef), NULL, false);

    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    CGImageRelease(mask);

    UIImage *img = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);

    return img;
}

- (void)remakeImage:(UIImage *)img {
    switch (self.typeCrop) {
        case AsyncImageCropLong: {
            CGRect cropRect = CGRectMake(img.size.width / 2 - self.frame.size.width / 2, 0, self.frame.size.width, self.frame.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
            // or use the UIImage wherever you like
            img = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
            break;
        case AsyncImageCropNone:

            break;

        default:
            break;
    }

    // set image
    if (self.maskImage) {
        // with mask
        UIImage *image = [self maskImage:img withMask:self.maskImage];
        self.image = image;

    } else {
        self.image = img;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.linkedUrl) {
        [[UIApplication sharedApplication] openURL:self.linkedUrl];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

@end
