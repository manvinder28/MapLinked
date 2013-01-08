//
//  MLUser.h
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/5/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLUser : NSObject
@property(nonatomic, strong) NSString *userUniqId;
@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *industry;
@property(nonatomic, strong) NSURL *pictureURL;
@property(nonatomic, strong) NSString *headline;
@property(nonatomic, strong) NSString *fullAddress;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, readwrite) NSInteger qbID;
@property(nonatomic, readwrite) CLLocationCoordinate2D lastLICoordinate;
@property(nonatomic, readwrite) CLLocationCoordinate2D lastQBCoordinate;
@property(nonatomic, strong) NSArray *positions;


- (id)initWithResponse:(NSData *)aData;
- (NSArray *)companiesIDs;

@end
