//
//  MLLinkedInManager.m
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/4/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLLinkedInManager.h"
#import "OAuthLoginViewController.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OATokenManager.h"
#import "Reachability.h"
#import "MLUser.h"
#import "MLCompany.h"

@interface MLLinkedInManager ()

@property(nonatomic, strong) OAuthLoginViewController *oAuthLoginViewController;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) NSOperationQueue *findCoordinateOperationQueue;

- (void)sendAPIRequestWithURL:(NSURL *)url HTTPMethod:(NSString *)method body:(NSData *)body delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;

@end

@implementation MLLinkedInManager

#pragma mark -
#pragma mark Private Init Methods

- (id)initSingleton {
    self = [super init];
    if (self) {
        self.locationManager = [CLLocationManager new];
        [self.locationManager startUpdatingLocation];
        [self.locationManager setDelegate:self];
    }
    return self;
}

#pragma mark -
#pragma mark Self Public Methods

+ (MLLinkedInManager *)sharedInstance {
    static MLLinkedInManager *linkedInManager = nil;

    if (linkedInManager != nil) {
        return linkedInManager;
    }

    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        linkedInManager = [[MLLinkedInManager alloc] initSingleton];
    });
    return linkedInManager;
}

- (void)saveAccessToken:(OAToken *)aToken andConsumer:(OAConsumer *)aConsumer {
    self.accessToken = aToken;
    self.consumer = aConsumer;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *savedArray = [NSMutableArray arrayWithObjects:aToken, aConsumer, nil];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:savedArray];
    [defaults setObject:data forKey:@"LIOauthInfo"];
    [defaults synchronize];
}

- (BOOL)loadSavedLIToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"LIOauthInfo"];
    if (data) {
        NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (savedArray.count > 1) {
            self.accessToken = [savedArray objectAtIndex:0];
            self.consumer = [savedArray objectAtIndex:1];
        }

    }
    if (!self.accessToken || !self.consumer) {
        return NO;
    }
    return YES;
}

- (BOOL)networkAvailability {
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    NSLog(@"Network available: %@", netStatus ? @"YES" : @"NO");
    return netStatus;
}

#pragma mark - User Info
#pragma mark -

- (void)updateUserInfo {
    [self getInfoWithUserID:nil delegate:self
          didFinishSelector:@selector(getUserInfo:didFinish:)
            didFailSelector:@selector(getUserInfo:didFail:)];
}

- (void)getUserInfo:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    MLUser *currentUser = [[MLUser alloc] initWithResponse:data];
    [MLDataManager sharedInstance].currentUser = currentUser;
    [[MLDataManager sharedInstance] addCompaniesIDs:currentUser.companiesIDs];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserInfoFinalNotification
                                                        object:nil];
}

- (void)getUserInfo:(OAServiceTicket *)ticket didFail:(NSData *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserInfoFailNotification
                                                        object:nil];
}

#pragma mark - Connections
#pragma mark -

- (void)updateUserConnections {
    [self getConnectionsOfCurrentUserDelegate:self
                            didFinishSelector:@selector(getConnections:didFinish:)
                              didFailSelector:@selector(getConnections:didFail:)];
}

- (void)getConnections:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:nil];
    NSLog(@"Response: %@", dictionary);

    for (NSDictionary *userInfo in [dictionary objectForKey:@"values"]) {
        NSData *connectionResponseData = userInfo.JSONData;
        MLUser *connection = [[MLUser alloc] initWithResponse:connectionResponseData];
        if (connection) {
            [[MLDataManager sharedInstance] addNewConnection:connection];
            [[MLDataManager sharedInstance] addCompaniesIDs:connection.companiesIDs];
        }
    }
    [self updateAllCompaniesInfo];
    [self updateAllUserQBLocations];

    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateConnectionsFinalNotification
                                                        object:self];
}

- (void)getConnections:(OAServiceTicket *)ticket didFail:(NSData *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateConnectionsFailNotification
                                                        object:self];
}

#pragma mark - Companies
#pragma mark -

- (void)updateAllCompaniesInfo {
    for (NSString *companyId in [MLDataManager sharedInstance].companiesIDs) {
        MLCompany *company = [[MLDataManager sharedInstance] cacheOfCompanyID:companyId];
        if (company) {
            [[MLDataManager sharedInstance] addNewCompany:company];
        } else {
            [self getInfoWithCompanyID:companyId
                              delegate:self
                     didFinishSelector:@selector(getCompaniesInfo:didFinish:)
                       didFailSelector:@selector(getCompaniesInfo:didFail:)];

        }
        
    }
}

- (void)getCompaniesInfo:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:nil];
    static int errorMessageCount = 0;
    if([response objectForKey:@"errorCode"]){
        if (errorMessageCount > 0) {
            return;
        }
        errorMessageCount++;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %@", [response objectForKey:@"status"]]
                                                        message:[response objectForKey:@"message"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    MLCompany *newCompany = [[MLCompany alloc] initWithResponse:data];
    [[MLDataManager sharedInstance] addNewCompany:newCompany];
}

- (void)getCompaniesInfo:(OAServiceTicket *)ticket didFail:(NSData *)data {

}

#pragma mark - Find Coordinates
#pragma mark -
- (void)findAllCompaniesCoordinates {
    for (MLCompany *company in [[MLDataManager sharedInstance] companies]) {
        [self findLocationCoordinateOfCompany:company];
    }
}

- (void)findLocationCoordinateOfCompany:(MLCompany *)aCompany {
    for (NSString *address in [aCompany addressesStrings]) {
        NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv",
                               [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                                   NSArray* locationItems = [responseString componentsSeparatedByString:@","];
                                   if (locationItems.count >= 4 && [[locationItems objectAtIndex:0] isEqualToString:@"200"]) {
                                       CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[locationItems objectAtIndex:2] doubleValue],
                                                                               [[locationItems objectAtIndex:3] doubleValue]);
                                       MLMapAnnotation *companyAnnotation = [[MLMapAnnotation alloc] initWithCoordinate:coordinate
                                                                                                                  title:aCompany.name
                                                                                                               subtitle:nil
                                                                                                               imageURL:aCompany.logoURL];
                                       companyAnnotation.mapAnnotationType = MLMapAnnotationTypeCompany;
                                       [[MLDataManager sharedInstance] addCompanyAnnotation:companyAnnotation];
                                       NSLog(@"Company:%@ Location: %f %f", aCompany.name, coordinate.latitude,coordinate.longitude);
                                   }
                                   else {
                                       CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
                                       [geoCoder geocodeAddressString:address
                                                    completionHandler:^(NSArray *placemarks, NSError *error) {
                                                        if (!error) {
                                                            CLPlacemark *currentLocation = (CLPlacemark *)[placemarks objectAtIndex:0];
                                                            MLMapAnnotation *companyAnnotation = [[MLMapAnnotation alloc] initWithCoordinate:currentLocation.location.coordinate
                                                                                                            title:aCompany.name subtitle:nil imageURL:aCompany.logoURL];
                                                            companyAnnotation.mapAnnotationType = MLMapAnnotationTypeCompany;
                                                            [[MLDataManager sharedInstance] addCompanyAnnotation:companyAnnotation];
                                                            NSLog(@"Company:%@ Location: %@", aCompany.name,currentLocation.location);
                                                        } else {
                                                            NSLog(@"Fail: Company:%@ Address: %@ ", aCompany.name,address);
                                                            NSLog(@"Geocode failed with error: %@", error);
                                                        }
                                                    }];
                                   }
                               }];
    }
}

- (void)findAllConnectionsCoordinates {
    for (MLUser *connection in [[MLDataManager sharedInstance] connections]) {
        [self findLocationCoordinateOfUser:connection];
    }
}

- (void)findLocationCoordinateOfUser:(MLUser *)aUser {
    if (aUser.lastQBCoordinate.latitude != 0.0 && aUser.lastQBCoordinate.longitude != 0.0) {
        NSString *annotationTitle = [NSString stringWithFormat:@"%@ %@",aUser.firstName, aUser.lastName];
        MLMapAnnotation *userAnnotation = [[MLMapAnnotation alloc] initWithCoordinate:aUser.lastQBCoordinate
                                                                                title:annotationTitle
                                                                             subtitle:nil
                                                                             imageURL:aUser.pictureURL];
        userAnnotation.mapAnnotationType = MLMapAnnotationTypeConnection;
        [[MLDataManager sharedInstance] addConnectionAnnotation:userAnnotation];
        return;
    }
//    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv",
//                               [aUser.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//                               NSArray *locationItems = [responseString componentsSeparatedByString:@","];
//                               NSString *annotationTitle = [NSString stringWithFormat:@"%@ %@",aUser.firstName, aUser.lastName];
//                               if (locationItems.count >= 4 && [[locationItems objectAtIndex:0] isEqualToString:@"200"]) {
//                                   CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[locationItems objectAtIndex:2] doubleValue],
//                                                                                                  [[locationItems objectAtIndex:3] doubleValue]);
//                                   MLMapAnnotation *userAnnotation = [[MLMapAnnotation alloc] initWithCoordinate:coordinate
//                                                                                            title:annotationTitle];
//                                   userAnnotation.mapAnnotationType = MLMapAnnotationTypeConnection;
//
//                                   [[MLDataManager sharedInstance] addConnectionAnnotation:userAnnotation];
//                                   NSLog(@"Connection:%@ Location: %f %f", annotationTitle, coordinate.latitude,coordinate.longitude);
//                               } else {
//                                   CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
//                                   [geoCoder geocodeAddressString:aUser.address
//                                                completionHandler:^(NSArray *placemarks, NSError *error) {                             
//                                                    if (!error) {
//                                                        CLPlacemark *currentLocation = (CLPlacemark *)[placemarks objectAtIndex:0];
//                                                        MLMapAnnotation *userAnnotation = [[MLMapAnnotation alloc] initWithCoordinate:currentLocation.location.coordinate
//                                                                                                            title:annotationTitle];
//                                                        userAnnotation.mapAnnotationType = MLMapAnnotationTypeConnection;
//
//                                                        [[MLDataManager sharedInstance] addConnectionAnnotation:userAnnotation];
//
//                                                        NSLog(@"Connection:%@ Location: %@", annotationTitle,currentLocation.location);
//                                                    } else {
//                                                        NSLog(@"Fail: Connection:%@ Address: %@ ", annotationTitle, aUser.address);
//                                                        NSLog(@"Geocode failed with error: %@", error);
//                                                    }
//                                                }];
//                               }
//                           }];
}

#pragma mark - Locations
#pragma mark -

- (void)updateAllUserQBLocations {
    QBLGeoDataGetRequest *searchMapARPointsRequest = [[QBLGeoDataGetRequest alloc] init];
    searchMapARPointsRequest.lastOnly = YES; // Only last location
    searchMapARPointsRequest.perPage = kGetGeoDataCount; // Pins limit for each page
    searchMapARPointsRequest.sortBy = GeoDataSortByKindCreatedAt;

    void (^__block searchMapARPointsBlockLogin)(Result *) = ^(Result *result) {
        if ([result isKindOfClass:[QBLGeoDataPagedResult class]]) {
            if (result.success) {
                QBLGeoDataPagedResult *geoDataSearchResult = (QBLGeoDataPagedResult *) result;
                for (QBLGeoData *geodata in geoDataSearchResult.geodata) {
                    CLLocationCoordinate2D userLocation = CLLocationCoordinate2DMake(geodata.latitude, geodata.longitude);
                    if (userLocation.latitude != 0 || userLocation.longitude != 0) {
                        [[MLDataManager sharedInstance] setUserQBLocation:userLocation
                                                               forQBLogin:geodata.user.login];
                    }
                    
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateAllUserQBLocationFinalNotification
                                                                    object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateAllUserQBLocationFailNotification
                                                                    object:nil];
            }
        }
    };

    [QBLocation geoDataWithRequest:searchMapARPointsRequest
                          delegate:self
                           context:(__bridge_retained void *) searchMapARPointsBlockLogin];
}

#pragma mark -
#pragma mark Private LinkedIn requests methods

- (void)getInfoWithUserID:(NSString *)aUserId delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/"];

    if (!aUserId) {;
        url = [url URLByAppendingPathComponent:@"~"];   //current user
    } else {
        url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"id=%@", aUserId]];
    }
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:(id,industry,first-name,last-name,headline,pictureUrl,educations,positions:(title,is-current,company:(name,id)),location:(name,country,postal-code),public-profile-url)", url.absoluteString]];

    [self sendAPIRequestWithURL:url
                     HTTPMethod:@"GET"
                           body:nil
                       delegate:aDelegate
              didFinishSelector:finishSelector
                didFailSelector:failSelector];
}

- (void)getConnectionsOfCurrentUserDelegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/connections"];
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:(id,industry,first-name,last-name,headline,pictureUrl,educations,positions:(title,is-current,company:(name,id)),location:(name,country,postal-code),public-profile-url)", url.absoluteString]];
    [self sendAPIRequestWithURL:url
                     HTTPMethod:@"GET"
                           body:nil delegate:(id)aDelegate
              didFinishSelector:finishSelector
                didFailSelector:failSelector];
}

- (void)getInfoWithCompanyID:(NSString *)aCompanyId delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.linkedin.com/v1/companies/%@", aCompanyId]];
    url = [NSURL URLWithString:[NSString stringWithFormat:
                                @"%@:(id,name,logo-url,description,locations:(address:(street1,city,state,country-code,region-code,postal-code)))", url.absoluteString]];

    [self sendAPIRequestWithURL:url
                     HTTPMethod:@"GET"
                           body:nil delegate:(id) aDelegate
              didFinishSelector:finishSelector
                didFailSelector:failSelector];
}

- (void)shareContentForTitle:(NSString *)aPostTitle postDescription:(NSString *)aPostDescription postURL:(NSString *)aPostURL postImageURL:(NSString *)aPostImageURL delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/shares"];

    NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys:
            [[NSDictionary alloc] initWithObjectsAndKeys:@"anyone", @"code", nil], @"visibility",
            [[NSDictionary alloc] initWithObjectsAndKeys:aPostTitle, @"title",
                                                         aPostDescription, @"description",
//                                                         aPostURL, @"submitted-url",
                                                         aPostImageURL, @"submitted-image-url", nil], @"content",
            aPostTitle, @"comment", nil];

    NSData *body = [update JSONData];

    [self sendAPIRequestWithURL:url
                     HTTPMethod:@"POST"
                           body:body
                       delegate:aDelegate
              didFinishSelector:finishSelector
                didFailSelector:failSelector];
}

- (void)sendAPIRequestWithURL:(NSURL *)url HTTPMethod:(NSString *)method body:(NSData *)body delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    if (self.accessToken == nil || self.consumer == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Need login", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![self networkAvailability]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"You do not appear to be connected to the internet", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;

    }
    NSLog(@"Sending API request to %@", url);

    // create and configure the URL request
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:self.accessToken
                                                                   callback:nil
                                                          signatureProvider:nil];
    [request setHTTPShouldHandleCookies:NO];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];

    if (method) {
        [request setHTTPMethod:method];
    }

    // prepare the request before setting the body, because OAuthConsumer wants to parse the body
    // for parameters to include in its signature, but LinkedIn doesn't work that way
    [request prepare];

    if ([body length]) {
        [request setHTTPBody:body];
    }

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:aDelegate
                didFinishSelector:finishSelector
                  didFailSelector:failSelector];
}

#pragma mark - feed
#pragma mark -
- (void)updateFeed {
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:@"Created at" forKey:@"sort_asc"];
    
    void(^resultBlock)(Result *) = ^(Result *result) {
        if(result.success && [result isKindOfClass:QBCOCustomObjectPagedResult.class]){
            QBCOCustomObjectPagedResult *getObjectsResult = (QBCOCustomObjectPagedResult *)result;
            if (getObjectsResult.count != [MLDataManager sharedInstance].feedArray.count) {
                [MLDataManager sharedInstance].feedArray = [NSMutableArray arrayWithArray:getObjectsResult.objects];
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFeedFinalNotification
                                                                    object:nil];
            }
            NSLog(@"Objects: %@, count: %d", getObjectsResult.objects, getObjectsResult.count);
        } else {
            NSLog(@"errors=%@", result.errors);
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFeedFailNotification
                                                                object:nil];
        }
    };
    
    [QBCustomObjects objectsWithClassName:@"Feed"
                          extendedRequest:getRequest
                                 delegate:self
                                  context:(__bridge void *)(resultBlock)] ;
    
}

- (void)sendFeed:(NSString *)aText title:(NSString *)aTitle delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {

    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"Feed";
    [object.fields setObject:aTitle forKey:@"title"];
    [object.fields setObject:aText forKey:@"text"];
    
    void(^resultBlock)(Result *) = ^(Result *result) {
        if(result.success && [result isKindOfClass:QBCOCustomObjectResult.class]){
//            QBCOCustomObjectResult *createObjectResult = (QBCOCustomObjectResult *)result;
            [self shareContentForTitle:@"QuickBlox"
                       postDescription:@"QuickBlox"
                               postURL:@"quickblox.com"
                          postImageURL:@"http://quickblox.com/wp-content/themes/quickblox2012/img/quickblox-logo.png"
                              delegate:aDelegate
                     didFinishSelector:finishSelector
                       didFailSelector:failSelector];
        } else {
            if (aDelegate && [aDelegate respondsToSelector:failSelector]) {
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [aDelegate performSelector:failSelector];
#       pragma clang diagnostic pop

            }
        }
    };
    [QBCustomObjects createObject:object delegate:[MLLinkedInManager sharedInstance] context:(__bridge void *)(resultBlock)];
    

}

#pragma mark - CLLocationManager delegate methods
#pragma mark -
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager performSelector:@selector(startUpdatingLocation)
                               withObject:nil afterDelay:60];

    CLLocationCoordinate2D currentCoordinate = newLocation.coordinate;

    MLUser *currentUser = [[MLDataManager sharedInstance] currentUser];
    if (currentUser) {
        currentUser.lastQBCoordinate = currentCoordinate;
    }

    NSLog(@"Location: latitude %+.6f, longitude %+.6f\n", currentCoordinate.latitude, currentCoordinate.longitude);

    @try {
        [[BaseService sharedService] token];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
        return;
    }

    QBLGeoData *geodata = [QBLGeoData geoData];
    geodata.latitude = currentCoordinate.latitude;
    geodata.longitude = currentCoordinate.longitude;
    [QBLocation createGeoData:geodata delegate:nil];
}

#pragma mark - QB delegate methods
#pragma mark -

- (void)completedWithResult:(Result *)result context:(void *)contextInfo {
    void(^block)(Result *result) = (__bridge void (^)(Result *result)) (contextInfo);
    block(result);
}

@end
