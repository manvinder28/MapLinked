//
//  MLConnectionInfoViewController.h
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/13/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLConnectionInfoViewController : UIViewController <UITextViewDelegate>
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil userID:(NSString *)uniqUserId;
@end
