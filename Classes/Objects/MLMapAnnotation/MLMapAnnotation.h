//
//  MLAppDelegate.m
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/3/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
// This class presents marker on the map view
//
#import <MapKit/MapKit.h>

enum {
	MLMapAnnotationTypeNone,
    MLMapAnnotationTypeCompany,
    MLMapAnnotationTypeConnection,
	MLMapAnnotationTypeCurrentUser
};
typedef NSInteger MLMapAnnotationType;

@interface MLMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, copy) NSURL *imageURL;
@property (nonatomic, readwrite) MLMapAnnotationType mapAnnotationType;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle;
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle subtitle:(NSString *)aSubtitle;
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle subtitle:(NSString *)aSubtitle imageURL:(NSURL *)aImageURL;
@end
