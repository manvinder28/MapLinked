//
//  MLDataManager.m
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/5/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLDataManager.h"
#import "MLUser.h"
#import "MLCompany.h"

@interface MLDataManager()

@property (nonatomic, strong) NSMutableArray *connections;
@property (nonatomic, strong) NSMutableArray *companies;
@property (nonatomic, strong) NSMutableArray *companiesAnnotations;
@property (nonatomic, strong) NSMutableArray *connectionsAnnotations;
@property (nonatomic, strong) NSArray *companiesIDs;
@property (nonatomic, strong) NSMutableArray *companiesCache;

@end

@implementation MLDataManager

+ (MLDataManager *)sharedInstance {
    static MLDataManager *dataManager = nil;

    if (dataManager != nil) {
        return dataManager;
    }

    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        dataManager = [[MLDataManager alloc] initSingleton];
    });
    return dataManager;
}

- (id)initSingleton {
    self = [super init];
    if (self) {
        self.connections = [NSMutableArray array];
        self.connectionsAnnotations = [NSMutableArray array];
        self.companiesAnnotations = [NSMutableArray array];
    }
    return self;
}

- (void)addNewConnection:(MLUser *)aConnection {
    [self.connections addObject:aConnection];
    NSArray *sortedArray;
    sortedArray = [self.connections sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(MLUser *)a firstName];
        NSString *second = [(MLUser *)b firstName];
        return [first compare:second];
    }];
    self.connections = [NSMutableArray arrayWithArray:sortedArray];
}

- (MLUser *)connectionWithID:(NSString *)uniqUserId {
    if (!uniqUserId) {
        return nil;
    }
    for (MLUser *user in self.connections) {
        if ([user.userUniqId isEqualToString:uniqUserId]) {
            return user;
        }
    }
    return nil;
}

- (void)setUserQBLocation:(CLLocationCoordinate2D)aLocation forQBLogin:(NSString *)aUserQBLogin {
    for (MLUser *user in self.connections) {
        NSString *userLogin = [NSString stringWithFormat:@"login%@", user.userUniqId];
        if ([userLogin isEqualToString:aUserQBLogin]) {
            user.lastQBCoordinate = aLocation;
            break;
        }
    }
    NSString *currentUserLogin = [NSString stringWithFormat:@"login%@", self.currentUser.userUniqId];
    if ([currentUserLogin isEqualToString:aUserQBLogin]) {
        self.currentUser.lastQBCoordinate = aLocation;
    }
}

- (void)clearAll {
    self.currentUser = nil;
    self.connections = nil;
    [self.companies removeAllObjects];
    self.companies = nil;
}
#pragma mark - Annotations
#pragma mark -

- (void)addCompanyAnnotation:(MLMapAnnotation *)aAnnotation {
    MLMapAnnotation *newAnnotation = aAnnotation;
    [self.companiesAnnotations addObject:newAnnotation];
    
    NSDictionary *annotationContainer = [NSDictionary dictionaryWithObject:newAnnotation
                                                                    forKey:@"annotation"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCompanyAnnotationDidAddedNotification
                                                        object:self
                                                      userInfo:annotationContainer];
}

- (void)addConnectionAnnotation:(MLMapAnnotation *)aAnnotation {
    MLMapAnnotation *newAnnotation = aAnnotation;
    [self.connectionsAnnotations addObject:newAnnotation];
    
    NSDictionary *annotationContainer = [NSDictionary dictionaryWithObject:newAnnotation
                                                                    forKey:@"annotation"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAnnotationDidAddedNotification
                                                        object:self
                                                      userInfo:annotationContainer];
}

#pragma mark - Companies
#pragma mark -

- (void)saveCompaniesCache {
    if (self.companiesCache) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.companiesCache]
                     forKey:@"companiesCache"];
        [defaults synchronize];
    }
}

- (NSArray *)loadCompaniesCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *companiesCache = nil;
    NSData *dataRepresentingSavedArray = [defaults objectForKey:@"companiesCache"];
    if (dataRepresentingSavedArray) {
        companiesCache = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    }
    return companiesCache ? companiesCache : [NSArray array];
}

- (void) clearCompaniesCashe {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"companiesCache"];
    [defaults synchronize];
}

- (void)addNewCompany:(MLCompany *)aCompany {
    if (!self.companiesCache) {
        self.companiesCache = [NSMutableArray arrayWithArray:[self loadCompaniesCache]];
    }
    if (!self.companies) {
        self.companies = [NSMutableArray array];
    }
    for (MLCompany *company in self.companies) {
        if ([company isEqual:aCompany]) {
            return;
        }
    }
    [self.companies addObject:aCompany];
    NSArray *sortedArray;
    sortedArray = [self.companies sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(MLCompany *)a name];
        NSString *second = [(MLCompany *)b name];
        return [first compare:second];
    }];
    self.companies = [NSMutableArray arrayWithArray:sortedArray];
    
    if (![self cacheOfCompanyID:aCompany.companyUniqId]) {
        [self.companiesCache addObject:aCompany];
        [self saveCompaniesCache];
    }
    
}

- (MLCompany *)companyWithID:(NSString *)aID {
    for (MLCompany *company in self.companies) {
        if ([[NSString stringWithFormat:@"%@", company.companyUniqId] isEqualToString:[NSString stringWithFormat:@"%@", aID]]) {
            return company;
        }
    }
    return nil;
}

- (MLCompany *)cacheOfCompanyID:(NSString *)aID {
    if (!self.companiesCache) {
        self.companiesCache = [NSMutableArray arrayWithArray:[self loadCompaniesCache]];
    }
    for (MLCompany *company in self.companiesCache) {
        if ([[NSString stringWithFormat:@"%@", company.companyUniqId] isEqualToString:[NSString stringWithFormat:@"%@", aID]]) {
            return company;
        }
    }
    return nil;
}

- (BOOL)isCashOfCompanyID:(NSString *)aID {
    return [self companyWithID:aID] != nil;
}

- (void)addCompanyID:(NSString *)aID {
    NSMutableArray *companiesIDs = [NSMutableArray arrayWithArray:self.companiesIDs];
    if (!companiesIDs) {
        companiesIDs = [NSMutableArray array];
    }
    [companiesIDs addObject:aID];
    self.companiesIDs = [[NSSet setWithArray:companiesIDs] allObjects];
}

- (void)addCompaniesIDs:(NSArray *)aIDs {
    NSMutableArray *companiesIDs = [NSMutableArray arrayWithArray:self.companiesIDs];
    if (!companiesIDs) {
        companiesIDs = [NSMutableArray array];
    }
    [companiesIDs addObjectsFromArray:aIDs];
    self.companiesIDs = [[NSSet setWithArray:companiesIDs] allObjects];
}
@end
