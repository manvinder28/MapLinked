//
//  MLISettingsViewController.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/20/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLSettingsViewController.h"
#import "MLAppDelegate.h"

@interface MLSettingsViewController ()

- (IBAction)clearCompaniesCashe:(id)sender;

@end

@implementation MLSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"DockSettings.png"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = anotherButton;
}

- (void)logout {
    [[MLDataManager sharedInstance] clearAll];
    [[MLLinkedInManager sharedInstance] saveAccessToken:nil andConsumer:nil];
    void (^__block finalBlockLogout)(Result *) = ^(Result *result) {
        if (result.success) {
            MLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLogOutNotification
                                                                object:nil];
            [appDelegate showLoginView];
        }

    };
    [QBUsers logOutWithDelegate:[MLLinkedInManager sharedInstance]
                        context:(__bridge_retained void *) finalBlockLogout];

}

- (IBAction)clearCompaniesCashe:(id)sender {
    [[MLDataManager sharedInstance] clearCompaniesCashe];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
