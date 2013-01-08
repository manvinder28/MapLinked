//
//  MLRootViewController.m
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/3/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLRootTabBarController.h"
#import "MLConnectionsTableViewController.h"
#import "MLAppDelegate.h"
#import "MLMapViewController.h"
#import "MLSettingsViewController.h"
#import "MLCompaniesTableViewController.h"
#import "MLFeedTableViewController.h"

@interface MLRootTabBarController ()
@end

@implementation MLRootTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        MLConnectionsTableViewController *connectionsTableViewCotroller = [[MLConnectionsTableViewController alloc] initWithNibName:@"MLConnectionsTableViewController" bundle:nil];
        UINavigationController *connectionsTableNavigationCotroller = [[UINavigationController alloc] initWithRootViewController:connectionsTableViewCotroller];
        connectionsTableNavigationCotroller.navigationBar.barStyle = UIBarStyleBlack;

        MLCompaniesTableViewController *companiesTableViewController = [[MLCompaniesTableViewController alloc] initWithNibName:@"MLCompaniesTableViewController" bundle:nil];
        UINavigationController *companiesTableNavigationCotroller = [[UINavigationController alloc] initWithRootViewController:companiesTableViewController];
        companiesTableNavigationCotroller.navigationBar.barStyle = UIBarStyleBlack;

        MLFeedTableViewController *feedTableViewController = [[MLFeedTableViewController alloc] initWithNibName:@"MLFeedTableViewController" bundle:nil];
        UINavigationController *feedTableNavigationController = [[UINavigationController alloc] initWithRootViewController:feedTableViewController];
        feedTableNavigationController.navigationBar.barStyle = UIBarStyleBlack;

        
        MLMapViewController *mapViewController = [[MLMapViewController alloc] initWithNibName:@"MLMapViewController"
                                                                                       bundle:nil];
        UINavigationController *mapNavigationCotroller = [[UINavigationController alloc] initWithRootViewController:mapViewController];
        mapNavigationCotroller.navigationBar.barStyle = UIBarStyleBlack;

        MLSettingsViewController *settingsViewController = [[MLSettingsViewController alloc] initWithNibName:@"MLSettingsViewController" bundle:nil];
        UINavigationController *settingsNavigationCotroller = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
        settingsNavigationCotroller.navigationBar.barStyle = UIBarStyleBlack;

        self.viewControllers = [NSArray arrayWithObjects:connectionsTableNavigationCotroller, companiesTableNavigationCotroller,feedTableNavigationController, mapNavigationCotroller, settingsNavigationCotroller, nil];
    }
    return self;
}

- (void)selectFirstTab {
    [self setSelectedIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentLoginViewController {

}
@end
