//
//  Performer.h
//  Core
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Performer : NSObject <Perform, Cancelable> {

    NSObject <QBActionStatusDelegate> *delegate;
    NSObject <Cancelable> *canceler;
    BOOL isCanceled;
    NSRecursiveLock *canceledLock;
    id context;
    BOOL verboseMode;
}
@property(nonatomic, retain) NSObject <QBActionStatusDelegate> *delegate;
@property(nonatomic, retain) NSObject <Cancelable> *canceler;
@property(nonatomic, retain) NSRecursiveLock *canceledLock;
@property(nonatomic, retain) id context;
@property(nonatomic) BOOL verboseMode;

@end

@interface Performer (ActionPerform)

- (void)performInBgAsyncWithDelegate:(NSObject <QBActionStatusDelegate> *)_delegate;

- (void)performAction;

- (void)actionInBg;

- (void)prepare;
@end

