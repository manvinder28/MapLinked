//
//  MLUser.m
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/5/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLUser.h"

@interface MLUser ()

@end

@implementation MLUser

- (id)initWithResponse:(NSData *)aData {
    self = [super init];
    if (self) {
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:aData
                                                                 options:kNilOptions
                                                                   error:nil];
        NSLog(@"%@",userInfo);
        self.userUniqId = [NSString stringWithString:[userInfo objectForKey:@"id"]];
        self.firstName = [userInfo objectForKey:@"firstName"];
        self.lastName = [userInfo objectForKey:@"lastName"];
        self.industry = [userInfo objectForKey:@"industry"];
        self.pictureURL = [NSURL URLWithString:[userInfo objectForKey:@"pictureUrl"]];
        self.headline = [userInfo objectForKey:@"headline"];
        self.lastLICoordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        self.lastQBCoordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        NSString *addressName = [[userInfo objectForKey:@"location"] objectForKey:@"name"];
        NSString *countryCode = [[[userInfo objectForKey:@"location"] objectForKey:@"country"] objectForKey:@"code"];
        self.fullAddress = (countryCode == nil) ? addressName : [NSString stringWithFormat:@"%@ %@", countryCode, addressName];
        self.address = addressName;
        
        NSMutableArray *connectionPositions = [NSMutableArray array];
        NSArray *positions = [[userInfo objectForKey:@"positions"] objectForKey:@"values"];
        for (NSDictionary *positionInfo in positions) {
            NSString *companyID = [[positionInfo objectForKey:@"company"] objectForKey:@"id"];
            NSString *companyName = [[positionInfo objectForKey:@"company"] objectForKey:@"name"];
            NSString *position = [positionInfo objectForKey:@"title"];
            NSNumber *isCurrent = [positionInfo objectForKey:@"isCurrent"];
            NSDictionary *userPosition = [NSDictionary dictionaryWithObjectsAndKeys:
                                          companyName, @"companyName",
                                          companyID, @"companyID",
                                          position, @"position",
                                          isCurrent, @"isCurrent",
                                          nil];
            
            [connectionPositions addObject:userPosition];
        }
        self.positions = [NSArray arrayWithArray:connectionPositions];
    }
    return self;
}

- (BOOL)isEqual:(id)compareObject {
    if (self == compareObject) {
        return YES;
    }
    if (![compareObject isKindOfClass:[self class]]) {
        return NO;
        
    }
    MLUser *compareUser = (MLUser *)compareObject;
    if ([compareUser.userUniqId isEqualToString:self.userUniqId]){
        return YES;
    } else {
        return NO;
    }
}
- (id)copyWithZone:(NSZone *)zone {
    MLUser *another = [[[self class] allocWithZone:zone] init];;
    another.userUniqId = [self.userUniqId copyWithZone:zone];
    another.firstName = [self.firstName copyWithZone:zone];
    another.lastName = [self.lastName copyWithZone:zone];
    another.industry = [self.industry copyWithZone:zone];
    another.pictureURL = [self.pictureURL copyWithZone:zone];
    another.headline = [self.headline copyWithZone:zone];
    another.fullAddress = [self.fullAddress copyWithZone:zone];
    another.qbID = self.qbID;
    another.lastLICoordinate = self.lastLICoordinate;
    another.lastQBCoordinate = self.lastQBCoordinate;
    another.positions = [self.positions copyWithZone:zone];

    return another;
}

- (id)copy
{
    return [self copyWithZone:NSDefaultMallocZone()];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userUniqId forKey:@"userUniqId"];
    [coder encodeObject:self.firstName forKey:@"firstName"];
    [coder encodeObject:self.lastName forKey:@"lastName"];
    [coder encodeObject:self.industry forKey:@"industry"];
    [coder encodeObject:self.pictureURL forKey:@"pictureURL"];
    [coder encodeObject:self.headline forKey:@"headline"];
    [coder encodeObject:self.fullAddress forKey:@"location"];
    [coder encodeInteger:self.qbID forKey:@"qbID"];
    [coder encodeDouble:self.lastLICoordinate.latitude forKey:@"lastLICoordinateLatitude"];
    [coder encodeDouble:self.lastLICoordinate.longitude forKey:@"lastLICoordinateLongitude"];
    [coder encodeDouble:self.lastQBCoordinate.latitude forKey:@"lastLICoordinateLatitude"];
    [coder encodeDouble:self.lastQBCoordinate.longitude forKey:@"lastLICoordinateLongitude"];
    [coder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.positions] forKey:@"positions"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [[MLUser alloc] init];
    if (self != nil) {
        self.userUniqId = [coder decodeObjectForKey:@"userUniqId"];
        self.firstName = [coder decodeObjectForKey:@"firstName"];
        self.lastName = [coder decodeObjectForKey:@"lastName"];
        self.industry = [coder decodeObjectForKey:@"industry"];
        self.pictureURL = [coder decodeObjectForKey:@"pictureURL"];
        self.headline = [coder decodeObjectForKey:@"headline"];
        self.fullAddress = [coder decodeObjectForKey:@"location"];
        self.qbID = [coder decodeIntegerForKey:@"qbID"];
        self.lastLICoordinate = CLLocationCoordinate2DMake([coder decodeDoubleForKey:@"lastLICoordinateLatitude"],
                                                           [coder decodeDoubleForKey:@"lastLICoordinateLongitude"]);
        self.lastQBCoordinate = CLLocationCoordinate2DMake([coder decodeDoubleForKey:@"lastLICoordinateLatitude"],
                                                           [coder decodeDoubleForKey:@"lastLICoordinateLongitude"]);
        self.positions = [NSKeyedUnarchiver unarchiveObjectWithData:[coder decodeObjectForKey:@"positions"]];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nid:%@\nlast name:%@\nfirst name:%@\nndustry:%@\npicture:%@\nheadline:%@ ",
            self.userUniqId,
            self.lastName,
            self.firstName,
            self.industry,
            self.pictureURL,
            self.headline];
}

- (NSArray *)companiesIDs {
    NSMutableArray *companiesIDs = [NSMutableArray array];
    for (NSDictionary *company in [self positions]) {
        NSString *companyID = [company objectForKey:@"companyID"];
        if (companyID) {
            [companiesIDs addObject:companyID];
        }
    }
    return [companiesIDs copy];
}
@end
