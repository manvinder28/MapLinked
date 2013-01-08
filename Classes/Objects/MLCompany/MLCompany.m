//
//  MLCompany.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/24/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLCompany.h"
@interface MLCompany()

@property (nonatomic, strong) NSString *companyUniqId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *logoURL;
@property (nonatomic, strong) NSString *descriptionString;
@property (nonatomic, strong) NSArray *addresses;

@end

@implementation MLCompany

- (id)initWithResponse:(NSData *)aData {
    self = [super init];
    if (self) {
        NSDictionary *companyInfo = [NSJSONSerialization JSONObjectWithData:aData
                                                                    options:kNilOptions
                                                                      error:nil];
        NSLog(@"%@",companyInfo);
        self.companyUniqId = [NSString stringWithFormat:@"%@",[companyInfo objectForKey:@"id"]];
        self.name = [NSString stringWithString:[companyInfo objectForKey:@"name"]];
        self.logoURL = [NSURL URLWithString:[companyInfo objectForKey:@"logoUrl"]];
        self.descriptionString = [companyInfo objectForKey:@"description"];

        NSMutableArray *addresses = [NSMutableArray array];
        NSArray *locations = [[companyInfo objectForKey:@"locations"] objectForKey:@"values"];
        for (NSDictionary *location in locations) {
            NSDictionary *address = [location objectForKey:@"address"];
            NSLog(@"Address: %@", address);
            NSDictionary *locationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [address objectForKey:@"city"], kABPersonAddressCityKey,
                                                [address objectForKey:@"countryCode"], kABPersonAddressCountryCodeKey,
                                                [address objectForKey:@"street1"], kABPersonAddressStreetKey,
                                                [address objectForKey:@"state"], kABPersonAddressStateKey,
                                                [address objectForKey:@"postalCode"], kABPersonAddressZIPKey, nil];
            [addresses addObject:[locationDictionary copy]];
        }
        self.addresses = [NSArray arrayWithArray:addresses];
    }
    return self;
}

- (NSArray *)addressesStrings {
    NSMutableArray *addresses = [NSMutableArray array];
    for (NSDictionary *addressInfo in self.addresses) {
        __weak NSMutableString *addressString = [NSMutableString string];
        for (NSString *addressComponent in [addressInfo allValues]) {
            if (addressComponent.length == 0) {
                continue;
            }
            [addressString appendString:addressComponent];
            if (![addressComponent isEqual:[[addressInfo allValues] lastObject]]) {
                [addressString appendString:@", "];
            }
        }
        if (addressString.length > 0) {
            [addresses addObject:[addressString copy]];
        }
    }
    return addresses;
}

- (BOOL)isEqual:(id)compareObject {
    if (self == compareObject) {
        return YES;
    }
    if (![compareObject isKindOfClass:[self class]]) {
        return NO;

    }
    MLCompany *compareCompany = (MLCompany*)compareObject;
    if ([compareCompany.companyUniqId isEqualToString:self.companyUniqId]){
        return YES;
    } else {
        return NO;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    MLCompany *another = [[MLCompany alloc] init];
    another.companyUniqId = [self.companyUniqId copyWithZone:zone];
    another.name = [self.name copyWithZone:zone];
    another.logoURL = [self.logoURL copyWithZone:zone];
    another.descriptionString = [self.descriptionString copyWithZone:zone];
    another.addresses = [self.addresses copyWithZone:zone];
    return another;
}

//- (id)copy
//{
//    return [self copyWithZone:NSDefaultMallocZone()];
//}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.companyUniqId forKey:@"companyUniqId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.logoURL forKey:@"logoURL"];
    [coder encodeObject:self.descriptionString forKey:@"description"];
    [coder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:self.addresses] forKey:@"addresses"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [[MLCompany alloc] init];
    if (self != nil) {
        self.companyUniqId = [coder decodeObjectForKey:@"companyUniqId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.logoURL = [coder decodeObjectForKey:@"logoURL"];
        self.descriptionString = [coder decodeObjectForKey:@"description"];
        self.addresses = [NSKeyedUnarchiver unarchiveObjectWithData:[coder decodeObjectForKey:@"addresses"]];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@",
            self.companyUniqId,
            self.name,
            self.logoURL,
            self.addresses];
}

@end
