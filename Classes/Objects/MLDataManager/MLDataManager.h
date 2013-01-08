//
//  MLDataManager.h
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/5/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLMapAnnotation.h"

#define kCompanyAnnotationDidAddedNotification @"companyAnnotationDidAddedNotification"
#define kConnectionAnnotationDidAddedNotification @"connectionAnnotationDidAddedNotification"

@class MLUser;
@class MLCompany;

@interface MLDataManager : NSObject

@property(nonatomic, strong, readonly) NSMutableArray *connections;
@property(nonatomic, strong, readonly) NSArray *companiesIDs;
@property(nonatomic, strong, readonly) NSMutableArray *companiesAnnotations;
@property(nonatomic, strong, readonly) NSMutableArray *companies;
@property(nonatomic, strong) NSMutableArray *feedArray;
@property(nonatomic, strong) MLUser *currentUser;

+ (MLDataManager *)sharedInstance;

- (void)addNewConnection:(MLUser *)aConnection;
- (MLUser *)connectionWithID:(NSString *)uniqUserId;

- (void)setUserQBLocation:(CLLocationCoordinate2D)aLocation forQBLogin:(NSString *)aUserQBLogin;

- (void)addNewCompany:(MLCompany *)aCompany;
- (MLCompany *)companyWithID:(NSString *)aID;
- (MLCompany *)cacheOfCompanyID:(NSString *)aID;
- (BOOL)isCashOfCompanyID:(NSString *)aID;
- (void)clearCompaniesCashe;
- (void)clearAll;

- (void)addCompanyAnnotation:(MLMapAnnotation *)aAnnotation;
- (void)addConnectionAnnotation:(MLMapAnnotation *)aAnnotation;

- (void)addCompanyID:(NSString *)aID;
- (void)addCompaniesIDs:(NSArray *)aIDs;

@end
