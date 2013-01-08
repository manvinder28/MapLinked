//
//  MLCompany.h
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/24/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLCompany : NSObject

@property (nonatomic, strong, readonly) NSString *companyUniqId;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSURL *logoURL;
@property (nonatomic, strong, readonly) NSString *descriptionString;
@property (nonatomic, strong, readonly) NSArray *addresses;
//@property (nonatomic, strong) NSMutableArray *coordinates;

- (id)initWithResponse:(NSData *)aData;
- (NSArray *)addressesStrings;

@end
