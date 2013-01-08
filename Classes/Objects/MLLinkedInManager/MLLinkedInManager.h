//
//  MLLinkedInManager.h
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/4/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#define kGetGeoDataCount 100

//Notifications

#define kUpdateUserInfoFinalNotification @"updateUserInfoFinalNotification"
#define kUpdateUserInfoFailNotification @"updateUserInfoFailNotification"

#define kUpdateConnectionsFinalNotification @"updateConnectionsFinalNotification"
#define kUpdateConnectionsFailNotification @"updateConnectionsFailNotification"

#define kUpdateCompaniesInfoFinalNotification @"updateCompaniesInfoFinalNotification"
#define kUpdateCompaniesInfoFailNotification @"updateCompaniesInfoFailNotification"

#define kUpdateAllUserQBLocationFinalNotification @"updateAllUserQBLocationFinalNotification"
#define kUpdateAllUserQBLocationFailNotification @"updateAllUserQBLocationFailNotification"

#define kUpdateFeedFinalNotification @"updateFeedFinalNotification"
#define kUpdateFeedFailNotification @"updateFeedFailNotification"

#define kLogOutNotification @"LogOutNotification"


@class OAToken;
@class OAConsumer;

@interface MLLinkedInManager : NSObject <QBActionStatusDelegate, CLLocationManagerDelegate>

@property(nonatomic, strong) OAToken *accessToken;
@property(nonatomic, strong) OAConsumer *consumer;

+ (MLLinkedInManager *)sharedInstance;

- (void)saveAccessToken:(OAToken *)aToken andConsumer:(OAConsumer *)aConsumer;

- (BOOL)loadSavedLIToken;

- (BOOL)networkAvailability;

- (void)updateUserConnections;

- (void)updateUserInfo;

- (void)findAllCompaniesCoordinates;
- (void)findAllConnectionsCoordinates;
- (void)updateFeed;
- (void)sendFeed:(NSString *)aText title:(NSString *)aTitle delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
@end
