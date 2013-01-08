//
//  MapPin.m
//  SimpleSample-location_users-ios
//
//  Created by Alexey Voitenko on 27.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLMapAnnotation.h"
@interface MLMapAnnotation ()

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

@implementation MLMapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate {
    self = [super init];
    if (self) {
        self.coordinate = aCoordinate;
    }
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle {
    self = [super init];
    if (self) {
        self.coordinate = aCoordinate;
        self.title = aTitle;
    }
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle subtitle:(NSString *)aSubtitle {
    self = [super init];
    if (self) {
        self.coordinate = aCoordinate;
        self.title = aTitle;
        self.subtitle = aSubtitle;
    }
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle subtitle:(NSString *)aSubtitle imageURL:(NSURL *)aImageURL {
    self = [super init];
    if (self) {
        self.coordinate = aCoordinate;
        self.title = aTitle;
        self.subtitle = aSubtitle;
        self.imageURL = aImageURL;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        self.coordinate = CLLocationCoordinate2DMake([aDecoder decodeDoubleForKey:@"latitude"],
                                                     [aDecoder decodeDoubleForKey:@"longitude"]);
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subtitle forKey:@"subtitle"];
    [aCoder encodeObject:self.title forKey:@"imageURL"];
}

-(id)copyWithZone:(NSZone *)zone {
    MLMapAnnotation *clone = [[[self class] allocWithZone:zone] init];
    clone.coordinate = self.coordinate;
    clone.title = self.title;
    clone.subtitle = self.subtitle;
    clone.imageURL = self.imageURL;
    return clone;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ (%f  %f)",
            self.title,
            self.subtitle,
            self.coordinate.latitude,
            self.coordinate.longitude];
}

@end
