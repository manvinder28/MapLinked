//
//  MLFeedDetailViewController.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 1/3/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MLFeedDetailViewController.h"

@interface MLFeedDetailViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextView *feedTextView;
@end

@implementation MLFeedDetailViewController

- (id)initWithFeed:(QBCOCustomObject *)aFeed {
    self = [super initWithNibName:@"MLFeedDetailViewController" bundle:nil];
    if (self) {
        self.titleLabel.text = [aFeed.fields objectForKey:@"title"];
        self.feedTextView.text = [aFeed.fields objectForKey:@"text"];
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

@end
