//
//  MLConnectionInfoViewController.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/13/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLConnectionInfoViewController.h"
#import "MLUser.h"
#import "AsyncImageView.h"

@interface MLConnectionInfoViewController ()
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, weak) IBOutlet AsyncImageView *userPictureImageView;
@property(nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *lastNameLabel;
@property(nonatomic, weak) IBOutlet UITextView *aboutTextView;
@property(nonatomic, weak) IBOutlet UITextView *headerTextView;


@end

@implementation MLConnectionInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil userID:(NSString *)uniqUserId {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.userID = uniqUserId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadOutViws];
}

- (void)reloadOutViws {
    MLUser *connection = [[MLDataManager sharedInstance] connectionWithID:self.userID];
    if (!connection) {
        return;
    }

    UIImage *defaultImage = [UIImage imageNamed:@"ghost_profile.png"];
    self.userPictureImageView.defaultImage = defaultImage;
    [self.userPictureImageView loadImageFromURL:connection.pictureURL];

    self.firstNameLabel.text = connection.firstName;
    self.lastNameLabel.text = connection.lastName;
    
    NSMutableString *headerString = [NSMutableString string];
    if (connection.industry && connection.industry.length > 0) {
        [headerString appendString:connection.industry];
    }
    if (connection.fullAddress && connection.fullAddress.length > 0) {
        if (headerString.length > 0) {
            [headerString appendFormat:@"\n"];
        }
        [headerString appendString:connection.address];
    }
    self.headerTextView.text = headerString;


    NSMutableString *aboutString = [NSMutableString string];
    if (connection.positions.count > 0){
        NSMutableString *currentPositions = [NSMutableString string];
        NSMutableString *previousPositions = [NSMutableString string];
        for (NSDictionary *positionInfo in connection.positions) {
            if ([[positionInfo objectForKey:@"isCurrent"] boolValue]) {
                if (currentPositions.length > 0) {
                    [currentPositions appendFormat:@", "];
                }
                [currentPositions appendFormat:@"%@ at %@", [positionInfo objectForKey:@"position"], [positionInfo objectForKey:@"companyName"]];
            } else {
                if (previousPositions.length != 0) {
                    [previousPositions appendFormat:@", "];
                }
                [previousPositions appendString:[positionInfo objectForKey:@"companyName"]];
            }
        }
        if (currentPositions.length > 0) {
            [aboutString appendFormat:@"\nCurrent: %@",currentPositions];
        } else {
            [aboutString appendFormat:@"\nCurrent: none"];
        }
        if (previousPositions.length > 0) {
            [aboutString appendFormat:@"\nPrevious: %@",previousPositions];
        }
    }
    self.aboutTextView.text = aboutString;
}

@end
